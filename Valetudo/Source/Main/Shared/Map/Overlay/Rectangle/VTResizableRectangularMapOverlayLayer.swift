//
//  VTRectangularVirtualRestrictionMapOverlayLayer.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//
import CoreGraphics
import QuartzCore
import UIKit

@MainActor
/// Backing layer that renders and edits a resizable rectangular map overlay.
final class VTResizableRectangularMapOverlayLayer: VTMapOverlayLayer {
    private static let controlBackgroundZPosition: CGFloat = 10000
    private static let controlIconZPosition: CGFloat = 10001

    /// Tracks whether the user is moving the full rectangle or resizing it from the handle.
    private enum Interaction {
        case move(offset: CGPoint)
        case resize(origin: CGPoint)
    }

    private let resizeControlLayer = CAShapeLayer()
    private let resizeIconLayer = CALayer()

    private var overlayModel: VTResizableRectangularMapOverlay?
    private var interaction: Interaction?

    // MARK: - Init

    /// Creates a rectangular overlay layer for the specified overlay identifier.
    override init(overlayID: UUID) {
        super.init(overlayID: overlayID)
    }

    /// Recreates the layer when copied by Core Animation.
    override init(layer: Any) {
        super.init(layer: layer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Applies the overlay model's current geometry and selection state to the layer tree.
    func configure(with overlay: VTResizableRectangularMapOverlay) {
        overlayModel = overlay
        isOverlaySelected = overlay.isSelected

        path = UIBezierPath(rect: overlay.rect).cgPath
        hitTestPath = UIBezierPath(rect: overlay.hitTestRect).cgPath
        fillColor = overlay.fillColor.cgColor
        strokeColor = overlay.strokeColor.cgColor
        lineWidth = 2.0
        lineDashPattern = overlay.isSelected ? [5, 4] : nil
        lineJoin = .round
        lineCap = .round

        attachControlsIfNeeded()
        configureControlLayer(resizeControlLayer, iconLayer: resizeIconLayer, frame: overlay.resizeControlFrame, image: .overlayResize)
        selectionStateDidChange()
    }

    /// Shows or hides the resize affordance depending on the current selection state.
    override func selectionStateDidChange() {
        resizeControlLayer.isHidden = !isOverlaySelected
        resizeIconLayer.isHidden = !isOverlaySelected
    }

    // MARK: - Interaction

    /// Selects the overlay when the tap lands inside any interactive region.
    override func tapAction(at point: CGPoint) -> VTMapOverlayTapAction {
        containsInteractivePoint(point) ? .select : .none
    }

    @discardableResult
    /// Starts either a move or resize interaction based on the touched hit target.
    override func beginInteraction(at point: CGPoint) -> Bool {
        guard let overlayModel else { return false }

        if isOverlaySelected, overlayModel.handle(at: point) == .resize {
            interaction = .resize(origin: overlayModel.rect.origin)
            return true
        }

        guard overlayModel.rect.contains(point) else { return false }
        interaction = .move(offset: CGPoint(x: point.x - overlayModel.rect.minX, y: point.y - overlayModel.rect.minY))
        return true
    }

    /// Updates the overlay model from the current drag point and refreshes the rendered rectangle.
    override func updateInteraction(to point: CGPoint) {
        guard let overlayModel, let interaction else { return }
        let containerBounds = superlayer?.bounds

        switch interaction {
        case let .move(offset):
            let proposedRect = CGRect(
                origin: CGPoint(x: point.x - offset.x, y: point.y - offset.y),
                size: overlayModel.rect.size
            )
            let boundedRect = proposedRect.clamped(to: containerBounds)
            overlayModel.updateRect(origin: boundedRect.origin, size: boundedRect.size)
        case let .resize(origin):
            let boundedResizePoint = point.clampedForResize(
                from: origin,
                minimumSideLength: VTResizableRectangularMapOverlay.minimumSideLength,
                to: containerBounds
            )
            overlayModel.updateRect(
                origin: origin,
                size: CGSize(
                    // Resizing always keeps the original corner fixed and derives the new size from
                    // the clamped drag point.
                    width: boundedResizePoint.x - origin.x,
                    height: boundedResizePoint.y - origin.y
                )
            )
        }

        configure(with: overlayModel)
    }

    @discardableResult
    /// Translates the rectangle by a keyboard or programmatic delta within the provided bounds.
    override func translate(by delta: CGPoint, within bounds: CGRect?) -> Bool {
        guard let overlayModel else { return false }

        let translatedRect = overlayModel.rect.offsetBy(dx: delta.x, dy: delta.y)
        let boundedRect = translatedRect.clamped(to: bounds)
        guard boundedRect.origin != overlayModel.rect.origin else { return false }

        overlayModel.updateRect(origin: boundedRect.origin, size: boundedRect.size)
        configure(with: overlayModel)
        return true
    }

    /// Clears the active drag state when the interaction ends.
    override func endInteraction() {
        interaction = nil
    }

    /// Removes selection controls before the overlay layer is discarded.
    override func prepareForRemoval() {
        resizeControlLayer.removeFromSuperlayer()
        resizeIconLayer.removeFromSuperlayer()
    }

    // MARK: - Control Layers

    /// Styles and positions the floating resize control and its icon.
    private func configureControlLayer(_ shapeLayer: CAShapeLayer, iconLayer: CALayer, frame: CGRect, image: UIImage?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        shapeLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: frame.height / 2).cgPath
        shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.92).cgColor
        shapeLayer.strokeColor = UIColor.black.withAlphaComponent(0.08).cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.12
        shapeLayer.shadowRadius = 3.0
        shapeLayer.shadowOffset = .zero

        iconLayer.contents = image?.withTintColor(.label, renderingMode: .alwaysOriginal).cgImage
        iconLayer.contentsGravity = .resizeAspect
        iconLayer.frame = frame.insetBy(dx: 4, dy: 4)
        iconLayer.zPosition = Self.controlIconZPosition

        CATransaction.commit()
    }

    /// Ensures the resize affordance layers are attached above the main overlay content.
    private func attachControlsIfNeeded() {
        guard let superlayer else { return }

        attachControlLayer(resizeControlLayer, to: superlayer, zPosition: Self.controlBackgroundZPosition)
        attachControlLayer(resizeIconLayer, to: superlayer, zPosition: Self.controlIconZPosition)
    }

    /// Reparents a control layer onto the overlay container and pins its z-position.
    private func attachControlLayer(_ layer: CALayer, to superlayer: CALayer, zPosition: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if layer.superlayer !== superlayer {
            layer.removeFromSuperlayer()
            superlayer.addSublayer(layer)
        }
        layer.zPosition = zPosition
        superlayer.addSublayer(layer)

        CATransaction.commit()
    }
}
