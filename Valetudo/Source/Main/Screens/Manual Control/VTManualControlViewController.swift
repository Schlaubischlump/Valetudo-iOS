//
//  VTManualControlViewController.swift
//  Valetudo
//
//  Created by David Klopp on 31.08.26.
//

import UIKit

@MainActor
final class VTManualControlViewController: VTViewController {
    private let client: VTAPIClientProtocol

    private var driver: VTManualControlDriver?
    private var activeMode: VTManualControlMode = .off
    private var currentVector = VTManualControlVector.zero
    private var moveTimer: Timer?
    private var movementRequestInFlight = false
    private var pendingVector: VTManualControlVector?
    private var cameraProperties: VTDuststreamingProperties?
    private weak var cameraViewController: VTDuststreamViewController?

    #if targetEnvironment(macCatalyst)
        private let inlineCameraContainerView = UIView()
        private var inlineCameraPlayerView: VTDuststreamPlayerView?
        private var inlineCameraProperties: VTDuststreamingProperties?
    #endif

    private lazy var manualControlTabs = makeManualControlTabs()

    init(client: VTAPIClientProtocol) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = "MANUAL_CONTROL".localized()
        navigationItem.subtitle = "MANUAL_CONTROL_SUBTITLE".localized()
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)

        configureContentView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await reconnectAndRefresh() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopMovement(resetPanels: true)
        #if targetEnvironment(macCatalyst)
            inlineCameraPlayerView?.stop()
        #endif
        super.viewWillDisappear(animated)
    }

    override func reconnectAndRefresh() async {
        setPanelsTransitioning(true)

        let capabilities = await Set((try? client.getCapabilities()) ?? [])
        driver = await VTManualControlDriver.resolve(capabilities: capabilities, client: client)

        let isEnabled = await (try? driver?.isEnabled(using: client)) ?? false
        let preferredMode = driver?.preferredMode ?? .keys
        let mode = isEnabled ? (activeMode == .off ? preferredMode : activeMode) : .off

        await refreshCameraAvailability(capabilities: capabilities)
        applyMode(mode, animated: false)
        setPanelsTransitioning(false)
    }

    private func makeManualControlTabs() -> VTManualControlTabBarController {
        let tabs = VTManualControlTabBarController()
        tabs.didSelectMode = { [weak self] mode in self?.transition(to: mode) }
        tabs.didChangeVector = { [weak self] vector in self?.updateMovement(vector) }
        tabs.didSelectCamera = { [weak self] in self?.openCamera() }
        tabs.setMode(activeMode)
        return tabs
    }

    private func configureContentView() {
        addChild(manualControlTabs)
        manualControlTabs.view.translatesAutoresizingMaskIntoConstraints = false

        #if targetEnvironment(macCatalyst)
            inlineCameraContainerView.backgroundColor = .systemBackground
            inlineCameraContainerView.clipsToBounds = true
            inlineCameraContainerView.isHidden = true

            let stackView = UIStackView(arrangedSubviews: [inlineCameraContainerView, manualControlTabs.view])
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                inlineCameraContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            ])
        #else
            view.addSubview(manualControlTabs.view)
            NSLayoutConstraint.activate([
                manualControlTabs.view.topAnchor.constraint(equalTo: view.topAnchor),
                manualControlTabs.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                manualControlTabs.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                manualControlTabs.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        #endif

        manualControlTabs.didMove(toParent: self)
    }

    private func makeCameraControlPanel() -> VTManualControlPanelView {
        let panel = VTManualControlPanelView(showsBackground: true)
        panel.didChangeVector = { [weak self] vector in self?.updateMovement(vector) }
        panel.setMode(activeMode, animated: false)
        panel.isHidden = activeMode == .off
        return panel
    }

    private var visiblePanels: [VTManualControlPanelView] {
        manualControlTabs.controlPanels + [cameraViewController?.controlPanel].compactMap(\.self)
    }

    private func transition(to mode: VTManualControlMode) {
        guard let driver, mode != activeMode else { return }
        let previousMode = activeMode
        stopMovement(resetPanels: true)
        setPanelsTransitioning(true)

        Task {
            do {
                if previousMode == .off, mode != .off {
                    try await driver.setEnabled(true, using: client)
                } else if mode == .off {
                    try await driver.setEnabled(false, using: client)
                }
                applyMode(mode, animated: true)
            } catch {
                applyMode(previousMode, animated: true)
            }
            setPanelsTransitioning(false)
        }
    }

    private func applyMode(_ mode: VTManualControlMode, animated: Bool) {
        activeMode = mode
        manualControlTabs.setMode(mode)
        cameraViewController?.controlPanel.setMode(mode, animated: animated)
        cameraViewController?.controlPanel.isHidden = mode == .off
    }

    private func setPanelsTransitioning(_ transitioning: Bool) {
        for panel in visiblePanels {
            panel.setTransitioning(transitioning)
        }
    }

    private func updateMovement(_ vector: VTManualControlVector) {
        guard activeMode != .off else { return }
        currentVector = vector

        if vector == .zero {
            stopMovement(resetPanels: false)
        } else if moveTimer == nil {
            enqueueMovement(vector)
            moveTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.enqueueMovement(self.currentVector)
                }
            }
        }
    }

    private func stopMovement(resetPanels: Bool) {
        let shouldSendStopCommand = activeMode != .off && (moveTimer != nil || currentVector != .zero)
        moveTimer?.invalidate()
        moveTimer = nil
        currentVector = .zero
        pendingVector = nil
        if shouldSendStopCommand {
            enqueueMovement(.zero)
        }
        if resetPanels {
            for panel in visiblePanels {
                panel.resetInput(notify: false)
            }
        }
    }

    private func enqueueMovement(_ vector: VTManualControlVector) {
        guard let driver else { return }
        if movementRequestInFlight {
            pendingVector = vector
            return
        }

        movementRequestInFlight = true
        Task {
            try? await driver.send(vector, using: client)
            movementRequestInFlight = false
            if let pendingVector {
                self.pendingVector = nil
                enqueueMovement(pendingVector)
            }
        }
    }

    private func refreshCameraAvailability(capabilities: Set<VTCapability>) async {
        guard capabilities.contains(.duststreaming),
              let configuration = try? await client.getDuststreamingConfiguration(),
              configuration.enabled,
              let properties = try? await client.getDuststreamingProperties()
        else {
            cameraProperties = nil
            manualControlTabs.setCamera(visible: false, enabled: false)
            #if targetEnvironment(macCatalyst)
                removeInlineCamera()
            #endif
            return
        }

        cameraProperties = properties
        manualControlTabs.setCamera(visible: true, enabled: properties.duststreamerInstalled)
        #if targetEnvironment(macCatalyst)
            if properties.duststreamerInstalled {
                await showInlineCamera(with: properties)
            } else {
                removeInlineCamera()
            }
        #endif
    }

    #if targetEnvironment(macCatalyst)
        private func showInlineCamera(with properties: VTDuststreamingProperties) async {
            if inlineCameraProperties == properties, let inlineCameraPlayerView {
                inlineCameraContainerView.isHidden = false
                inlineCameraPlayerView.start()
                return
            }

            removeInlineCamera()
            let streamURL = await client.getDuststreamingStreamURL()
            let playerView = VTDuststreamPlayerView(
                streamURL: streamURL,
                dimensions: CGSize(width: properties.width, height: properties.height)
            )
            playerView.translatesAutoresizingMaskIntoConstraints = false
            inlineCameraContainerView.addSubview(playerView)

            let aspectRatio = CGFloat(properties.width) / CGFloat(properties.height)
            let preferredWidth = playerView.widthAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.widthAnchor,
                constant: -48
            )
            preferredWidth.priority = .defaultHigh
            let preferredHeight = playerView.heightAnchor.constraint(
                equalTo: inlineCameraContainerView.heightAnchor,
                constant: -32
            )
            preferredHeight.priority = .defaultHigh
            NSLayoutConstraint.activate([
                playerView.centerXAnchor.constraint(equalTo: manualControlTabs.view.safeAreaLayoutGuide.centerXAnchor),
                playerView.centerYAnchor.constraint(equalTo: inlineCameraContainerView.centerYAnchor),
                playerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                playerView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                playerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                playerView.bottomAnchor.constraint(lessThanOrEqualTo: inlineCameraContainerView.bottomAnchor, constant: -16),
                playerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                playerView.widthAnchor.constraint(lessThanOrEqualToConstant: 760),
                playerView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: aspectRatio),
                preferredWidth,
                preferredHeight,
            ])

            inlineCameraProperties = properties
            inlineCameraPlayerView = playerView
            inlineCameraContainerView.isHidden = false
            playerView.start()
        }

        private func removeInlineCamera() {
            inlineCameraPlayerView?.stop()
            inlineCameraPlayerView?.removeFromSuperview()
            inlineCameraPlayerView = nil
            inlineCameraProperties = nil
            inlineCameraContainerView.isHidden = true
        }
    #endif

    @objc private func openCamera() {
        guard let cameraProperties else { return }

        Task {
            let streamURL = await client.getDuststreamingStreamURL()
            let camera = VTDuststreamViewController(
                streamURL: streamURL,
                dimensions: CGSize(width: cameraProperties.width, height: cameraProperties.height),
                controlPanel: makeCameraControlPanel()
            )
            camera.modalPresentationStyle = .fullScreen
            camera.didDismiss = { [weak self] in
                self?.stopMovement(resetPanels: true)
                self?.cameraViewController = nil
            }
            cameraViewController = camera
            applyMode(activeMode, animated: false)
            #if !targetEnvironment(macCatalyst)
                VTAppDelegate.orientationOverride = .landscape
                setNeedsUpdateOfSupportedInterfaceOrientations()
            #endif
            present(camera, animated: true)
        }
    }

    @objc private func applicationDidEnterBackground() {
        stopMovement(resetPanels: true)
        cameraViewController?.dismissCamera(animated: false)
        #if targetEnvironment(macCatalyst)
            inlineCameraPlayerView?.stop()
        #endif
    }
}
