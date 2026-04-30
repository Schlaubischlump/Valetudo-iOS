//
//  VTSplitViewController.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

private let kInspectorTag = 101

/// Hosts the app's primary split layout and owns the shared robot control controller.
///
/// The robot control controller is reused across regular and compact layouts. In regular
/// layouts it lives in the split view's inspector column; in compact layouts it is
/// temporarily detached so Home can present that same instance as a sheet.
class VTSplitViewController: UISplitViewController, UISplitViewControllerDelegate, UINavigationControllerDelegate {
    let client: VTAPIClientProtocol
    /// Single source of truth for robot-control UI and state across layout changes.
    let robotControlViewController: VTRobotControlViewController
    private var selectedSidebarItem: VTSidebarItem = .home

    lazy var sidebar: VTSidebarViewController = .init(client: client)
    private lazy var sidebarNavigationController = UINavigationController(rootViewController: sidebar)
    let detail: UINavigationController = .init(rootViewController: UIViewController())

    init(client: VTAPIClientProtocol, style: UISplitViewController.Style) {
        self.client = client
        robotControlViewController = VTRobotControlViewController(client: client)
        super.init(style: style)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        detail.delegate = self
        primaryBackgroundStyle = .sidebar
        preferredDisplayMode = .oneBesideSecondary
        preferredPrimaryColumnWidth = 250

        sidebar.didSelectItem = { [weak self] item in
            guard let self else { return }
            updateDetail(for: item, animated: isCompact)
        }
        sidebar.navigationItem.titleView = VTNavigationTitleView(
            image: .appLogo,
            title: "VALETUDO".localized(),
            subtitle: "VALETUDO_SUBTITLE".localized()
        )

        setViewController(sidebarNavigationController, for: .primary)
        setViewController(detail, for: .secondary)
        setViewController(robotControlViewController, for: .inspector)

        updateDetail(for: .home, animated: false) // Select default
        updateNavigationChrome()
        sidebar.setSelectedItem(selectedSidebarItem)
    }

    /// Attaches or detaches the shared robot control controller from the inspector column.
    ///
    /// UIKit does not allow presenting a controller modally while it is still parented by
    /// the split view. Compact layouts therefore replace the inspector with a placeholder
    /// before Home presents the shared controller as a sheet.
    func setRobotControlViewControllerPresentedInInspector(_ isPresented: Bool) {
        let targetInspector = isPresented ? robotControlViewController : UIViewController()
        guard viewController(for: .inspector) !== targetInspector else { return }

        setViewController(targetInspector, for: .inspector)
        if isPresented {
            show(.inspector)
        } else {
            hide(.inspector)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavigationChrome()
        sidebar.setSelectedItem(selectedSidebarItem)
    }

    /// Rebuilds the secondary column for the selected sidebar item.
    func updateDetail(for item: VTSidebarItem, animated: Bool) {
        selectedSidebarItem = item
        sidebar.setSelectedItem(item)

        let vc: UIViewController = switch item {
        case .home: VTHomeViewController(client: client, robotControlViewController: robotControlViewController)
        case .consumables: VTConsumablesViewController(client: client)
        case .systemInformation: VTSystemInformationViewController(client: client)
        case .manualControl: VTManualControlViewController(client: client)
        case .highResolutionManualControl: VTHighResolutionManualControlViewController(client: client)
        case .updater: VTUpdaterViewController(client: client)
        case .log: VTLogViewController(client: client)
        case .timers: VTTimersViewController(client: client)
        case .map: VTMapOptionsViewController(client: client)
        case .robot: UIViewController()
        }
        vc.title = item.title
        detail.setViewControllers([vc], animated: animated)
        updateNavigationChrome()

        if isCompact {
            showDetailViewController(detail, sender: self)
        }
    }

    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        updateDetailNavigationButtons(for: viewController)
    }

    @objc
    private func didTapInspectorToggle() {
        if isShowing(.inspector) {
            hide(.inspector)
        } else {
            show(.inspector)
        }
        updateNavigationChrome()
    }

    private func updateNavigationChrome() {
        sidebar.setShowsEventButton(isCompact && sidebarNavigationController.topViewController === sidebar)

        if let topViewController = detail.topViewController {
            updateDetailNavigationButtons(for: topViewController)
        }
    }

    /// Ensures the inspector toggle only appears where the split layout can actually show it.
    private func updateDetailNavigationButtons(for viewController: UIViewController) {
        var rightItems = viewController.navigationItem.rightBarButtonItems ?? []

        if rightItems.isEmpty, let rightItem = viewController.navigationItem.rightBarButtonItem {
            rightItems = [rightItem]
        }

        rightItems.removeAll { $0.tag == kInspectorTag }

        if !isCompact {
            rightItems.insert(makeInspectorToggleBarButtonItem(), at: 0)
        }

        viewController.navigationItem.rightBarButtonItems = rightItems.isEmpty ? nil : rightItems
    }

    private func makeInspectorToggleBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(
            image: .sidebarRight,
            style: .plain,
            target: self,
            action: #selector(didTapInspectorToggle)
        )
        item.title = "CONTROL".localized()
        item.tag = kInspectorTag
        return item
    }
}
