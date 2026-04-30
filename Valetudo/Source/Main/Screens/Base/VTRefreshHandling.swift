//
//  VTRefreshHandling.swift
//  Valetudo
//
//  Created by David Klopp on 13.11.25.
//

import UIKit

@MainActor
protocol VTRefreshHandling: AnyObject {
    func refreshContent(animated: Bool) async
}

extension VTViewController: VTRefreshHandling {
    func refreshContent(animated _: Bool) async {
        await reconnectAndRefresh()
    }
}

extension VTCollectionViewController: VTRefreshHandling {
    func refreshContent(animated _: Bool) async {
        await reconnectAndRefresh()
    }
}

extension UICollectionViewController {
    func configureRefreshControlIfSupported(_ refreshControl: UIRefreshControl, action: Selector) {
        // Refresh control is not available on macOS.
        #if !targetEnvironment(macCatalyst)
            collectionView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: action, for: .valueChanged)
        #endif
    }
}

// TODO: If more than one is visible we would rather refresh both at least on macOS
extension UIViewController {
    @MainActor
    func activeRefreshHandler() -> (any VTRefreshHandling)? {
        if let presentedViewController {
            return presentedViewController.activeRefreshHandler()
        }

        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.activeRefreshHandler()
        }

        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.activeRefreshHandler()
        }

        if let splitViewController = self as? UISplitViewController {
            // Prefer detail content over the inspector so keyboard refresh targets
            // the active screen instead of shared robot controls in regular mode.
            let preferredColumns: [UISplitViewController.Column] = [
                .secondary,
                .supplementary,
                .primary,
                .compact,
                .inspector,
            ]

            for column in preferredColumns {
                guard let viewController = splitViewController.viewController(for: column) else { continue }
                if let handler = viewController.activeRefreshHandler() {
                    return handler
                }
            }
        }

        for child in children.reversed() {
            if let handler = child.activeRefreshHandler() {
                return handler
            }
        }

        return self as? any VTRefreshHandling
    }
}
