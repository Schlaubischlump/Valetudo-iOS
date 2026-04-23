//
//  VTSplitViewController.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

class VTSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    let client: VTAPIClientProtocol

    lazy var sidebar: VTSidebarViewController = {
        VTSidebarViewController(client: client)
    }()
    let detail: UINavigationController = UINavigationController(rootViewController: UIViewController())
    let inspector: UIViewController
    
    init(client: VTAPIClientProtocol, style: UISplitViewController.Style) {
        self.client = client
        inspector = VTRobotControlViewController(client: client)
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        primaryBackgroundStyle = .sidebar
        preferredDisplayMode = .oneBesideSecondary
        preferredPrimaryColumnWidth = 250

        sidebar.didSelectItem = { [weak self] item in
            guard let self else { return }
            self.updateDetail(for: item, animated: self.isCompact)
        }
        sidebar.navigationItem.titleView = VTNavigationTitleView(
            image: UIImage(named: "Logo"),
            title: "VALETUDO".localized(),
            subtitle: "VALETUDO_SUBTITLE".localized()
        )

        let sidebarNavController = UINavigationController(rootViewController: sidebar)
        setViewController(sidebarNavController, for: .primary)
        setViewController(detail, for: .secondary)
        setViewController(inspector, for: .inspector)

        updateDetail(for: .home, animated: false) // Select default
    }

    func updateDetail(for item: VTSidebarItem, animated: Bool) {
        let vc: UIViewController = switch item {
        case .home:                         VTHomeViewController(client: client)
        case .consumables:                  VTConsumablesViewController(client: client)
        case .systemInformation:            VTSystemInformationViewController(client: client)
        case .manualControl:                VTManualControlViewController(client: client)
        case .highResolutionManualControl:  VTHighResolutionManualControlViewController(client: client)
        case .updater:                      VTUpdaterViewController(client: client)
        case .log:                          VTLogViewController(client: client)
        case .timers:                       VTTimersViewController(client: client)
        case .robot:                        UIViewController()
        default:                            UIViewController()
        }
        vc.title = item.title
        detail.setViewControllers([vc], animated: animated)
        
        if (isCompact) {
            showDetailViewController(detail, sender: self)
        }
    }
}
