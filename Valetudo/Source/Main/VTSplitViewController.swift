//
//  VTSplitViewController.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

class VTSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    let client: VTAPIClientProtocol

    let sidebar = VTSidebarViewController()
    let detail = UINavigationController(rootViewController: UIViewController())
    
    init(client: VTAPIClientProtocol, style: UISplitViewController.Style) {
        self.client = client
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

        sidebar.didSelectItem = { [weak self] index in
            guard let self else { return }
            self.updateDetail(for: index, animated: self.isCompact)
        }

        let sidebarNavController = UINavigationController(rootViewController: sidebar)
        setViewController(sidebarNavController, for: .primary)
        setViewController(detail, for: .secondary)

        updateDetail(for: 0, animated: false) // Select default
    }

    func updateDetail(for index: Int, animated: Bool) {
        let vc: UIViewController
        switch index {
        case 0:
            vc = VTMapViewController(client: client)
        default:
            vc = UIViewController()
        }
        vc.title = sidebar.items[index].title
        detail.setViewControllers([vc], animated: animated)
        if (isCompact) {
            showDetailViewController(detail, sender: self)
        }
    }
}
