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
final class VTRectangularVirtualRestrictionMapOverlayLayer: VTMapOverlayLayer {
    private static let controlBackgroundZPosition: CGFloat = 10000
    private static let controlIconZPosition: CGFloat = 10001

    private enum Interaction {
        case move(offset: CGPoint)
        case resize(origin: CGPoint)
    }

    private let resizeControlLayer = CAShapeLayer()
    private let resizeIconLayer = CALayer()

    private var overlayModel: VTRectangularVirtualRestrictionMapOverlay?
    private var interaction: Interaction?

    override init(overlayID: UUID) {
        super.init(overlayID: overlayID)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with overlay: VTRectangularVirtualRestrictionMapOverlay) {
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

    override func selectionStateDidChange() {
        resizeControlLayer.isHidden = !isOverlaySelected
        resizeIconLayer.isHidden = !isOverlaySelected
    }

    override func tapAction(at point: CGPoint) -> VTMapOverlayTapAction {
        containsInteractivePoint(point) ? .select : .none
    }

    @discardableResult
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
                minimumSideLength: VTRectangularVirtualRestrictionMapOverlay.minimumSideLength,
                to: containerBounds
            )
            overlayModel.updateRect(
                origin: origin,
                size: CGSize(
                    width: boundedResizePoint.x - origin.x,
                    height: boundedResizePoint.y - origin.y
                )
            )
        }

        configure(with: overlayModel)
    }

    @discardableResult
    override func translate(by delta: CGPoint, within bounds: CGRect?) -> Bool {
        guard let overlayModel else { return false }

        let translatedRect = overlayModel.rect.offsetBy(dx: delta.x, dy: delta.y)
        let boundedRect = translatedRect.clamped(to: bounds)
        guard boundedRect.origin != overlayModel.rect.origin else { return false }

        overlayModel.updateRect(origin: boundedRect.origin, size: boundedRect.size)
        configure(with: overlayModel)
        return true
    }

    override func endInteraction() {
        interaction = nil
    }

    override func prepareForRemoval() {
        resizeControlLayer.removeFromSuperlayer()
        resizeIconLayer.removeFromSuperlayer()
    }

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

    private func attachControlsIfNeeded() {
        guard let superlayer else { return }

        attachControlLayer(resizeControlLayer, to: superlayer, zPosition: Self.controlBackgroundZPosition)
        attachControlLayer(resizeIconLayer, to: superlayer, zPosition: Self.controlIconZPosition)
    }

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
