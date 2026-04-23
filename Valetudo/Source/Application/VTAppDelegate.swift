//
//  VTAppDelegate.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//  
//

import UIKit

@main
class VTAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        let refreshCommand = UIKeyCommand(
            title: "REFRESH".localized(),
            action: #selector(refreshFromCommand),
            input: "R",
            modifierFlags: [.command]
        )
        refreshCommand.discoverabilityTitle = "REFRESH".localized()

        let refreshMenu = UIMenu(options: .displayInline, children: [refreshCommand])
        builder.insertChild(refreshMenu, atStartOfMenu: .view)
    }

    @objc
    private func refreshFromCommand() {
        Task { @MainActor in
            guard let refreshHandler = activeRefreshHandler() else { return }
            await refreshHandler.refreshContent(animated: false)
        }
    }

    @MainActor
    private func activeRefreshHandler() -> (any VTRefreshHandling)? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }

            let windows = windowScene.windows.sorted { lhs, rhs in
                if lhs.isKeyWindow == rhs.isKeyWindow {
                    return lhs.windowLevel.rawValue > rhs.windowLevel.rawValue
                }

                return lhs.isKeyWindow && !rhs.isKeyWindow
            }

            for window in windows where !window.isHidden {
                guard let rootViewController = window.rootViewController,
                      let refreshHandler = rootViewController.activeRefreshHandler() else { continue }
                return refreshHandler
            }
        }

        return nil
    }
}
