//
//  VTViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.03.26.
//
import UIKit

/// Base collection view controller with shared refresh and adaptive layout handling.
class VTCollectionViewController: UICollectionViewController, VTViewControllerProtocol {
    var lastKnownViewWidth: CGFloat = 0
    var lastKnownViewDesign: VTViewDesign?
    private var hasCompletedInitialSelfSizingPass = false

    @objc
    private func sceneWillEnterForeground(_: Notification) {
        Task {
            guard self.viewIfLoaded?.window != nil else { return }
            await self.reconnectAndRefresh()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.selfSizingInvalidation = .enabledIncludingConstraints

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasCompletedInitialSelfSizingPass else { return }
        hasCompletedInitialSelfSizingPass = true

        // Fix collection view size on macOS catalyst
        collectionView.collectionViewLayout.invalidateLayout()
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
