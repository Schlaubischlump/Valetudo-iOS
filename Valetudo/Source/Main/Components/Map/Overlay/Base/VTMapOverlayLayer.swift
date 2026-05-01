//
//  VTMapOverlayLayer.swift
//  Valetudo
//
//  Created by David Klopp on 29.04.26.
//
import CoreGraphics
import Foundation
import QuartzCore

enum VTMapOverlayTapAction {
    case none
    case select
}

/// Shape layer used to render a transient overlay and expose a custom hit-test path.
@MainActor
class VTMapOverlayLayer: CAShapeLayer {
    private(set) var overlayID: UUID
    var hitTestPath: CGPath?
    var isOverlaySelected: Bool = false {
        didSet {
            guard oldValue != isOverlaySelected else { return }
            selectionStateDidChange()
        }
    }

    init(overlayID: UUID) {
        self.overlayID = overlayID
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        overlayID = UUID()
        super.init(layer: layer)
    }

    /// Evaluates the overlay-specific hit target instead of the layer's bounds.
    func containsOverlayPoint(_ point: CGPoint) -> Bool {
        hitTestPath?.contains(point) ?? false
    }

    /// Evaluates whether the point should activate the overlay for selection or interaction.
    ///
    /// Subclasses can widen this beyond the visible line body, for example by including handle hit
    /// targets that are intentionally larger than the rendered affordances.
    func containsInteractivePoint(_ point: CGPoint) -> Bool {
        containsOverlayPoint(point)
    }

    /// Allows overlays to react to taps beyond simple selection.
    func tapAction(at point: CGPoint) -> VTMapOverlayTapAction {
        containsInteractivePoint(point) ? .select : .none
    }

    /// Lets an overlay layer react to selection changes, for example by revealing handles.
    func selectionStateDidChange() {}

    /// Starts an overlay-specific interaction at the given map-space point.
    @discardableResult
    func beginInteraction(at point: CGPoint) -> Bool {
        containsInteractivePoint(point)
    }

    /// Applies an in-progress interaction update in map coordinates.
    func updateInteraction(to _: CGPoint) {}

    /// Moves the overlay by a fixed delta, typically from keyboard input.
    @discardableResult
    func translate(by _: CGPoint, within _: CGRect?) -> Bool {
        false
    }

    /// Ends the current interaction and clears temporary state.
    func endInteraction() {}

    /// Removes any auxiliary sibling layers owned by the overlay before the main layer is detached.
    func prepareForRemoval() {}
}
