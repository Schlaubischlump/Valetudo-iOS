//
//  VTRobotBarButton.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import UIKit

class VTRobotBarButtonItem: UIBarButtonItem {
    private weak var parentViewController: UIViewController?

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        super.init()
        title = "ROBOTS".localized()
        image = .robotNavigationItem
        target = self
        action = #selector(goBackToRobotsListScreen(_:))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func goBackToRobotsListScreen(_: Any) {
        guard let sceneDelegate = parentViewController?.view.window?.windowScene?.delegate as? VTSceneDelegate else {
            return
        }

        sceneDelegate.showRobotsListScreen(animated: true)
    }
}
