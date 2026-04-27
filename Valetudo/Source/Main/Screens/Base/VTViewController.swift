//
//  VTViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.03.26.
//
import UIKit

class VTViewController: UIViewController, VTViewControllerProtocol {
    var lastKnownViewWidth: CGFloat = 0
    var lastKnownViewDesign: VTViewDesign?

    @objc
    private func sceneWillEnterForeground(_: Notification) {
        Task {
            guard self.viewIfLoaded?.window != nil else { return }
            await self.reconnectAndRefresh()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // We don't need any cleanup, since we are using target / action pattern
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneWillEnterForeground(_:)),
            name: .scene​Did​Request​Refresh​After​Background,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recomputeViewMetricsChange()
    }

    @MainActor
    func reconnectAndRefresh() async {
        // Override me
    }

    func viewDesign(forAvailableWidth width: CGFloat, traitCollection: UITraitCollection) -> VTViewDesign {
        guard width >= 520, traitCollection.horizontalSizeClass != .compact else { return .compact }
        return .regular
    }

    func viewMetricsDidChange() {
        // Override me
    }

    func viewDesignDidChange(to _: VTViewDesign) {
        // Override me
    }
}
