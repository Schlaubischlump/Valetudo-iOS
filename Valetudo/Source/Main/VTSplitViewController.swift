//
//  VTSplitViewController.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

private let kInspectorTag = 101

class VTSplitViewController: UISplitViewController, UISplitViewControllerDelegate, UINavigationControllerDelegate {
    let client: VTAPIClientProtocol

    lazy var sidebar: VTSidebarViewController = .init(client: client)
    private lazy var sidebarNavigationController = UINavigationController(rootViewController: sidebar)
    private lazy var inspectorToggleBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: .sidebarRight,
            style: .plain,
            target: self,
            action: #selector(didTapInspectorToggle)
        )
        item.title = "CONTROL".localized()
        item.tag = kInspectorTag
        return item
    }()

    let detail: UINavigationController = .init(rootViewController: UIViewController())
    let inspector: UIViewController

    init(client: VTAPIClientProtocol, style: UISplitViewController.Style) {
        self.client = client
        inspector = VTRobotControlViewController(client: client)
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
        setViewController(inspector, for: .inspector)

        updateDetail(for: .home, animated: false) // Select default
        updateNavigationChrome()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavigationChrome()
    }

    func updateDetail(for item: VTSidebarItem, animated: Bool) {
        let vc: UIViewController = switch item {
        case .home: VTHomeViewController(client: client)
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

    private func updateDetailNavigationButtons(for viewController: UIViewController) {
        var rightItems = viewController.navigationItem.rightBarButtonItems ?? []

        if rightItems.isEmpty, let rightItem = viewController.navigationItem.rightBarButtonItem {
            rightItems = [rightItem]
        }

        rightItems.removeAll { $0.tag == inspectorToggleBarButtonItem.tag }

        if !isCompact {
            rightItems.append(inspectorToggleBarButtonItem)
        }

        viewController.navigationItem.rightBarButtonItems = rightItems.isEmpty ? nil : rightItems
    }
}
