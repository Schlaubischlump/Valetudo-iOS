//
//  VTViewControllerProtocol.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//

import UIKit

/// Shared API for view-controller based screens that support refresh and adaptive design changes.
@MainActor
protocol VTViewControllerProtocol: AnyObject {
    /// Cached width from the last metrics pass.
    var lastKnownViewWidth: CGFloat { get set }

    /// Cached semantic design from the last metrics pass.
    var lastKnownViewDesign: VTViewDesign? { get set }

    /// Trait environment used to resolve the current semantic design.
    var traitCollection: UITraitCollection { get }

    /// Backing view whose bounds drive adaptive layout decisions.
    var view: UIView! { get }

    /// The currently resolved design for this view based on width and trait environment.
    var currentViewDesign: VTViewDesign { get }

    /// Trigger a reconnect and refresh cycle for the current screen.
    func reconnectAndRefresh() async

    /// Resolves the semantic design mode for the current view metrics.
    func viewDesign(forAvailableWidth width: CGFloat, traitCollection: UITraitCollection) -> VTViewDesign

    /// Called when view metrics changed enough that subclasses may want to react.
    func viewMetricsDidChange()

    /// Called when the semantic view design changed between compact and regular.
    func viewDesignDidChange(to design: VTViewDesign)

    /// Recomputes width and design changes and dispatches the corresponding callbacks.
    func recomputeViewMetricsChange()
}

extension VTViewControllerProtocol {
    /// The currently resolved design for this view based on width and trait environment.
    var currentViewDesign: VTViewDesign {
        let width = view.bounds.width
        guard width > 0 else { return .compact }
        return viewDesign(forAvailableWidth: width, traitCollection: traitCollection)
    }

    /// Shared implementation that updates cached metrics and dispatches the corresponding hooks.
    func recomputeViewMetricsChange() {
        let width = view.bounds.width
        guard width > 0 else { return }

        let previousWidth = lastKnownViewWidth
        let widthChanged = abs(width - previousWidth) > 1
        lastKnownViewWidth = width

        let design = viewDesign(forAvailableWidth: width, traitCollection: traitCollection)
        let designChanged = design != lastKnownViewDesign
        lastKnownViewDesign = design

        guard widthChanged || designChanged else { return }
        viewMetricsDidChange()

        guard designChanged else { return }
        viewDesignDidChange(to: design)
    }
}
