//
//  UISplitViewController + Compact.swift
//  Valetudo
//
//  Created by David Klopp on 19.05.25.
//
import UIKit

extension UIViewController {
    var isCompact: Bool {
        traitCollection.horizontalSizeClass == .compact
    }

    @MainActor
    func showError(title: String, message: String?, okButtonTitle: String = "OK".localized(), animated: Bool = true) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: okButtonTitle, style: .cancel))
        presentAlertControllerSafely(alert, animated: animated)
    }

    @MainActor
    func activeAlertPresenter() -> UIViewController? {
        if let presentedViewController, !presentedViewController.isBeingDismissed {
            return presentedViewController.activeAlertPresenter()
        }

        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController
        {
            return visibleViewController.activeAlertPresenter()
        }

        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController
        {
            return selectedViewController.activeAlertPresenter()
        }

        if let splitViewController = self as? UISplitViewController {
            for viewController in splitViewController.viewControllers.reversed() {
                if let presenter = viewController.activeAlertPresenter() {
                    return presenter
                }
            }
        }

        for child in children.reversed() {
            if let presenter = child.activeAlertPresenter() {
                return presenter
            }
        }

        return viewIfLoaded?.window != nil ? self : nil
    }

    @MainActor
    func presentAlertControllerSafely(
        _ alertController: UIAlertController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let presenter = activeAlertPresenter()
            ?? view.window?.rootViewController?.activeAlertPresenter()
            ?? self

        if let popover = alertController.popoverPresentationController,
           popover.sourceView == nil
        {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 1,
                height: 1
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(alertController, animated: animated, completion: completion)
    }
}
