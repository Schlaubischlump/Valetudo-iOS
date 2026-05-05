//
//  VTHomeViewController.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//

import UIKit

private let bottomPad: CGFloat = 20
private let sheetCornerRadius: CGFloat = 39.0

/// Hosts the live home map, robot status, and adaptive control presentation for the selected robot.
@MainActor
final class VTHomeViewController: VTViewController {
    /// Shared API client passed through to child controllers and local observers.
    private let client: VTAPIClientProtocol
    /// Reused control surface that moves between compact sheet presentation and regular inspector presentation.
    private let robotControlViewController: VTRobotControlViewController
    /// Home-specific map child that owns mode switching, overlays, and legend behavior.
    private let homeMapViewController: VTHomeMapViewController
    /// Compact status card showing battery and current robot state.
    private let robotStatusView = VTRobotStatusView()

    /// Task that keeps robot status synchronized with the `.stateAttributes` event stream.
    private var eventObservationTask: Task<Void, Never>?
    /// Token used to unregister the active state-attribute observer.
    private var observerToken: VTListenerToken?
    /// Tracks whether the state stream has connected once so reconnects can trigger a refresh.
    private var hasConnectedStateStream = false

    /// Currently observed sheet view whose frame drives live legend repositioning in compact layout.
    private weak var observedSheetView: UIView?
    /// Reused events button so navigation-item updates can preserve split-owned buttons explicitly.
    private var eventBarButtonItem: VTValetudoEventBarButtonItem?
    /// Reused mode selector button so navigation-item updates can preserve split-owned buttons explicitly.
    private var modeBarButtonItem: UIBarButtonItem?
    /// Cached mode menu entries emitted by the home map child.
    private var modeOptions: [VTHomeMapViewController.ModeOption] = []
    /// Currently active home cleaning/navigation mode.
    private var selectedMode: VTHomeMapViewController.Mode = .segment

    /// Creates the home screen with a shared API client and reusable robot controls.
    init(client: VTAPIClientProtocol, robotControlViewController: VTRobotControlViewController) {
        self.client = client
        self.robotControlViewController = robotControlViewController
        homeMapViewController = VTHomeMapViewController(
            client: client,
            robotControlViewController: robotControlViewController
        )

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    /// Builds the home screen hierarchy and binds child-controller callbacks.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupChildController()
        setupRobotStatusView()
        bindHomeMapController()
        configureNavigationItems()
    }

    /// Starts adaptive control-surface presentation once the controller is visible.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, _) in
            self.updateRobotControlViewPresentation(animated: false)
        }

        updateRobotControlViewPresentation(animated: true)
    }

    /// Starts observing live robot status updates whenever the home screen becomes active.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startStateObservation()
    }

    /// Stops robot status observation when leaving the home screen.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopStateObservation()
    }

    // MARK: - Refresh

    /// Restarts state observation after the shared reconnect flow completes.
    override func reconnectAndRefresh() async {
        stopStateObservation()
        startStateObservation()
    }

    // MARK: - View Configuration

    /// Embeds the home map controller as the full-screen background child.
    private func setupChildController() {
        addChild(homeMapViewController)
        homeMapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(homeMapViewController.view)

        NSLayoutConstraint.activate([
            homeMapViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            homeMapViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeMapViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeMapViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        homeMapViewController.didMove(toParent: self)
    }

    /// Installs the compact robot-status card in the upper-left corner.
    private func setupRobotStatusView() {
        robotStatusView.translatesAutoresizingMaskIntoConstraints = false
        robotStatusView.backgroundColor = .systemBackground
        view.addSubview(robotStatusView)

        NSLayoutConstraint.activate([
            robotStatusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            robotStatusView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            robotStatusView.heightAnchor.constraint(equalToConstant: 86),
            robotStatusView.widthAnchor.constraint(equalToConstant: 118),
        ])
    }

    // MARK: - Child Controller Binding

    /// Connects the home map controller's mode callbacks to navigation updates.
    private func bindHomeMapController() {
        homeMapViewController.onModeTitleChanged = { [weak self] title in
            self?.navigationItem.title = title
        }
        homeMapViewController.onModeOptionsChanged = { [weak self] options, selectedMode in
            self?.modeOptions = options
            self?.selectedMode = selectedMode
            self?.configureNavigationItems()
        }
    }

    // MARK: - Navigation Items

    /// Rebuilds the mode menu and preserves split-owned navigation buttons when possible.
    private func configureNavigationItems() {
        let modeActions = modeOptions.map { option in
            UIAction(
                title: option.mode.menuTitle,
                attributes: option.isEnabled ? [] : [.disabled],
                state: option.mode == selectedMode ? .on : .off
            ) { [weak self] _ in
                self?.homeMapViewController.selectMode(option.mode)
            }
        }

        let previousModeBarButtonItem = modeBarButtonItem
        let modeButton = UIBarButtonItem(
            title: selectedMode.menuTitle,
            image: UIImage(systemName: "chevron.down.circle"),
            primaryAction: nil,
            menu: UIMenu(title: "", children: modeActions)
        )

        let preservedItems = (navigationItem.rightBarButtonItems ?? []).filter {
            $0 !== eventBarButtonItem && $0 !== previousModeBarButtonItem
        }

        let eventButton = eventBarButtonItem ?? VTValetudoEventBarButtonItem(client: client, parentViewController: self)
        eventBarButtonItem = eventButton
        modeBarButtonItem = modeButton

        navigationItem.rightBarButtonItems = preservedItems + [
            eventButton,
            modeButton,
        ]
    }

    // MARK: - State Observation

    /// Starts observing state-attribute events and applies the latest robot status to the HUD.
    private func startStateObservation() {
        guard eventObservationTask == nil else { return }

        eventObservationTask = Task { [weak self] in
            guard let self else { return }

            if let state = try? await client.getStateAttributes() {
                await updateRobotStatus(with: state)
            }

            let (token, stream) = await client.registerEventObserver(for: .stateAttributes)
            observerToken = token
            hasConnectedStateStream = false

            for await event in stream {
                switch event {
                case .didConnect:
                    if hasConnectedStateStream {
                        if let state = try? await client.getStateAttributes() {
                            await updateRobotStatus(with: state)
                        }
                    } else {
                        hasConnectedStateStream = true
                    }
                case let .didReceiveData(state):
                    await updateRobotStatus(with: state)
                case let .didReceiveError(message):
                    log(message: message, forSubsystem: .stateAttribute, level: .error)
                default:
                    break
                }
            }
        }
    }

    /// Stops observing state-attribute events and unregisters the active listener token.
    private func stopStateObservation() {
        eventObservationTask?.cancel()
        eventObservationTask = nil
        hasConnectedStateStream = false

        if let token = observerToken {
            let client = client
            Task { await client.removeEventObserver(token: token, for: .stateAttributes) }
            observerToken = nil
        }
    }

    /// Updates the status HUD with the latest robot state and battery information.
    private func updateRobotStatus(with state: VTStateAttributeList) async {
        robotStatusView.update(forStatus: state.statusState.description, batteryLevel: state.batterLevel)
    }

    // MARK: - Robot Control Presentation

    /// Switches between compact sheet presentation and regular inspector presentation.
    fileprivate func updateRobotControlViewPresentation(animated: Bool = false) {
        let splitVC = splitViewController as? VTSplitViewController

        if isCompact {
            splitVC?.setRobotControlViewControllerPresentedInInspector(false)
            presentControlSheet(animated: animated)
        } else {
            dismissControlSheet(animated: animated) { [weak splitVC] in
                splitVC?.setRobotControlViewControllerPresentedInInspector(true)
            }
            resetLegendPositionForRegularLayout()
        }
    }

    /// Presents or updates the compact control sheet used on narrow layouts.
    private func presentControlSheet(animated: Bool) {
        guard isCompact else { return }
        let sheetVC = robotControlViewController
        sheetVC.modalPresentationStyle = .pageSheet

        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.bottom(), .middle(), .top()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = sheetCornerRadius
            sheet.delegate = self
            sheet.largestUndimmedDetentIdentifier = .middle
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheetVC.isModalInPresentation = true
        }

        guard presentedViewController != sheetVC else {
            updateLegendPosition(basedOn: sheetVC.view.frame.height, animate: animated)
            return
        }

        updateLegendPosition(
            basedOn: UISheetPresentationController.Detent.bottomHeight,
            animate: animated
        )

        present(sheetVC, animated: animated) { [weak self, weak sheetVC] in
            self?.startObservingSheetFrame(for: sheetVC?.view)
        }
    }

    /// Dismisses the compact control sheet if it is currently presented.
    private func dismissControlSheet(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedViewController === robotControlViewController else {
            completion?()
            return
        }

        stopObservingSheetFrame()
        presentedViewController?.dismiss(animated: animated, completion: completion)
    }

    // MARK: - Sheet Observation

    /// Starts observing the presented sheet view so legend placement can track its live height.
    private func startObservingSheetFrame(for view: UIView?) {
        guard let view else { return }
        if observedSheetView === view { return }

        stopObservingSheetFrame()
        view.addObserver(self, forKeyPath: "frame", options: [.new, .initial], context: nil)
        observedSheetView = view
    }

    /// Stops observing the currently tracked sheet view.
    private func stopObservingSheetFrame() {
        guard let observedSheetView else { return }
        observedSheetView.removeObserver(self, forKeyPath: "frame")
        self.observedSheetView = nil
    }

    /// Responds to sheet frame changes by updating the home map legend position.
    override func observeValue(
        forKeyPath keyPath: String?,
        of _: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context _: UnsafeMutableRawPointer?
    ) {
        guard keyPath == "frame",
              let frame = (change?[.newKey] as? NSValue)?.cgRectValue
        else { return }

        Task<Void, Never> { @MainActor [weak self] in
            guard let self,
                  isCompact,
                  presentedViewController === robotControlViewController
            else { return }

            updateLegendPosition(basedOn: frame.height, animate: false)
        }
    }

    // MARK: - Legend Positioning

    /// Positions the legend above the compact control sheet while respecting safe-area padding.
    private func updateLegendPosition(basedOn sheetHeight: CGFloat, animate: Bool) {
        let bottomInset = view.safeAreaInsets.bottom
        let midHeight = UISheetPresentationController.Detent.middleHeight
        let inset = max(
            -bottomPad - sheetHeight + bottomInset,
            -bottomPad - midHeight
        )

        if animate {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.homeMapViewController.setLegendBottomInset(inset)
            }
        } else {
            homeMapViewController.setLegendBottomInset(inset)
        }
    }

    /// Restores the default legend inset used in regular-width layouts.
    private func resetLegendPositionForRegularLayout() {
        homeMapViewController.setLegendBottomInset(-bottomPad)
    }
}

// MARK: - UISheetPresentationControllerDelegate

extension VTHomeViewController: UISheetPresentationControllerDelegate {
    /// Animates the legend when the compact control sheet moves between known detents.
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let identifier = sheetPresentationController.selectedDetentIdentifier else { return }

        let height: CGFloat? = switch identifier {
        case .bottom:
            UISheetPresentationController.Detent.bottomHeight
        case .middle:
            UISheetPresentationController.Detent.middleHeight
        default:
            nil
        }

        if let height {
            updateLegendPosition(basedOn: height, animate: true)
        }
    }
}
