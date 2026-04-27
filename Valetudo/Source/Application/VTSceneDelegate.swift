//
//  VTSceneDelegate.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//
//

import UIKit

private struct VTSelectedRobot: Codable {
    let id: String
    let lastURL: URL
}

class VTSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private enum InitialScreen {
        case robotsList
        case mainInterface(URL)
    }

    private static let launchScreenDisplayDuration: TimeInterval = 1.0

    var window: UIWindow?
    private var didEnterBackground = false

    @CodableAppStorage("selectedRobot")
    private var selectedRobot: VTSelectedRobot? = nil

    /// Startup flow:
    /// 1. Install the custom launch screen as the initial root view controller.
    /// 2. In parallel, decide whether to restore the last robot or show the robots list
    ///    and wait for the minimum launch screen display duration.
    /// 3. Transition away from the launch screen once both steps are complete.
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            fatalError("Expected scene of type UIWindowScene but got an unexpected type")
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        window.rootViewController = VTLaunchScreenViewController()
        window.makeKeyAndVisible()

        Task { @MainActor in
            await showInitialScreen(afterLaunchScreenIn: windowScene)
        }
    }

    @MainActor
    func showRobotsListScreen(animated: Bool) {
        guard let window,
              let windowScene = window.windowScene else { return }

        clearToolbarIfNeeded(for: windowScene)

        let robotsListNavigationController = makeRobotsListNavigationController(for: windowScene)
        guard animated else {
            window.rootViewController = robotsListNavigationController
            return
        }

        if let launchScreenViewController = window.rootViewController as? VTLaunchScreenViewController {
            launchScreenViewController.animateDismiss { [weak self] in
                self?.setRootViewController(robotsListNavigationController, in: window, animated: true)
            }
        } else {
            setRootViewController(robotsListNavigationController, in: window, animated: true)
        }
    }

    @MainActor
    private func presentUnableToResolveAlert(for robot: VTMDNSRobot) {
        let alert = UIAlertController(
            title: robot.name,
            message: "UNABLE_TO_RESOLVE_ROBOT_URL".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))

        window?.rootViewController?.present(alert, animated: true)
    }

    @MainActor
    private func makePrimaryAndShowMainInterface(robot: VTMDNSRobot, in windowScene: UIWindowScene, animated: Bool) async {
        guard let robotURL = await robot.getUrl() else {
            presentUnableToResolveAlert(for: robot)
            return
        }

        selectedRobot = VTSelectedRobot(id: robot.id, lastURL: robotURL)
        showMainInterface(for: robotURL, in: windowScene, animated: animated)
    }

    @MainActor
    private func showMainInterface(for robotURL: URL, in windowScene: UIWindowScene, animated: Bool) {
        let apiClient = makeAPIClient(baseURL: robotURL)
        let splitViewController = VTSplitViewController(client: apiClient, style: .doubleColumn)

        configureToolbarIfNeeded(for: windowScene)

        guard let window else { return }
        guard animated else {
            window.rootViewController = splitViewController
            return
        }

        if let launchScreenViewController = window.rootViewController as? VTLaunchScreenViewController {
            launchScreenViewController.animateDismiss { [weak self] in
                self?.setRootViewController(splitViewController, in: window, animated: true)
            }
            return
        }

        setRootViewController(splitViewController, in: window, animated: true)
    }

    private func setRootViewController(_ viewController: UIViewController, in window: UIWindow, animated: Bool) {
        guard animated else {
            window.rootViewController = viewController
            return
        }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: [.transitionCrossDissolve, .allowAnimatedContent]
        ) {
            window.rootViewController = viewController
        }
    }

    private func makeRobotsListNavigationController(for windowScene: UIWindowScene) -> UINavigationController {
        let robotsViewController = VTRobotsListViewController()
        robotsViewController.onSelectRobot = { [weak self] robot in
            Task { @MainActor in
                await self?.makePrimaryAndShowMainInterface(robot: robot, in: windowScene, animated: true)
            }
        }

        let navigationController = UINavigationController(rootViewController: robotsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    @MainActor
    private func showInitialScreen(afterLaunchScreenIn windowScene: UIWindowScene) async {
        async let initialScreen = makeInitialScreen()
        async let launchScreenDelay = waitForLaunchScreenDisplayDuration()

        let screen = await initialScreen
        await launchScreenDelay

        switch screen {
        case .robotsList:
            showRobotsListScreen(animated: true)
        case let .mainInterface(robotURL):
            showMainInterface(for: robotURL, in: windowScene, animated: true)
        }
    }

    private func waitForLaunchScreenDisplayDuration() async {
        let nanoseconds = UInt64(Self.launchScreenDisplayDuration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)
    }

    @MainActor
    private func makeInitialScreen() async -> InitialScreen {
        guard let selectedRobot else {
            return .robotsList
        }

        let startupTimeout = Self.launchScreenDisplayDuration / 2

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = startupTimeout
        configuration.timeoutIntervalForResource = startupTimeout
        let apiClient = makeAPIClient(baseURL: selectedRobot.lastURL, configuration: configuration)

        if await apiClient.canReachValetudo() {
            return .mainInterface(selectedRobot.lastURL)
        }

        let robots = await VTMDNSClient(scanTimeout: startupTimeout).scanForRobots()
        guard let robot = robots.first(where: { $0.id == selectedRobot.id }),
              let robotURL = await robot.getUrl()
        else {
            return .robotsList
        }

        self.selectedRobot = VTSelectedRobot(id: robot.id, lastURL: robotURL)
        return .mainInterface(robotURL)
    }

    private func configureToolbarIfNeeded(for windowScene: UIWindowScene) {
        #if targetEnvironment(macCatalyst)
            let toolbar = NSToolbar(identifier: NSToolbar.Identifier("VTSceneDelegate.Toolbar"))
            toolbar.delegate = self
            toolbar.displayMode = .iconOnly
            toolbar.allowsUserCustomization = false

            windowScene.titlebar?.toolbar = toolbar
            windowScene.titlebar?.toolbarStyle = .unified
        #endif
    }

    private func clearToolbarIfNeeded(for windowScene: UIWindowScene) {
        #if targetEnvironment(macCatalyst)
            windowScene.titlebar?.toolbar = nil
        #endif
    }

    func sceneDidEnterBackground(_: UIScene) {
        didEnterBackground = true
    }

    func sceneWillEnterForeground(_: UIScene) {
        guard didEnterBackground else { return }

        didEnterBackground = false
        NotificationCenter.default.post(name: .scene​Did​Request​Refresh​After​Background, object: nil)
    }
}
