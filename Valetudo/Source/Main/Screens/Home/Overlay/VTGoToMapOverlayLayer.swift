//
//  VTGoToMapOverlayLayer.swift
//  Valetudo
//
//  Created by David Klopp on 04.05.26.
//
import UIKit

/// Overlay layer responsible for drawing and dragging the home screen's go-to target crosshair.
@MainActor
final class VTGoToMapOverlayLayer: VTMapOverlayLayer {
    private enum Interaction {
        case move(offset: CGPoint)
    }

    /// Backing overlay model currently rendered by this layer.
    private var overlayModel: VTGoToMapOverlay?
    /// Active drag interaction, if the user is currently moving the crosshair.
    private var interaction: Interaction?

    /// Rebuilds the crosshair path and hit region from the current overlay model state.
    func configure(with overlay: VTGoToMapOverlay) {
        overlayModel = overlay
        isOverlaySelected = overlay.isSelected

        let path = UIBezierPath()
        let radius: CGFloat = 12.0
        path.addArc(withCenter: overlay.centerPoint, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        path.move(to: CGPoint(x: overlay.centerPoint.x - radius - 6, y: overlay.centerPoint.y))
        path.addLine(to: CGPoint(x: overlay.centerPoint.x + radius + 6, y: overlay.centerPoint.y))
        path.move(to: CGPoint(x: overlay.centerPoint.x, y: overlay.centerPoint.y - radius - 6))
        path.addLine(to: CGPoint(x: overlay.centerPoint.x, y: overlay.centerPoint.y + radius + 6))

        self.path = path.cgPath
        hitTestPath = UIBezierPath(ovalIn: overlay.hitFrame).cgPath
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineWidth = 2.0
        lineDashPattern = overlay.isSelected ? [5, 4] : nil
        lineCap = .round
    }

    @discardableResult
    override func beginInteraction(at point: CGPoint) -> Bool {
        guard let overlayModel, overlayModel.hitFrame.contains(point) else { return false }
        interaction = .move(offset: CGPoint(x: point.x - overlayModel.centerPoint.x, y: point.y - overlayModel.centerPoint.y))
        return true
    }

    override func updateInteraction(to point: CGPoint) {
        guard let overlayModel, let interaction else { return }

        switch interaction {
        case let .move(offset):
            let bounds = superlayer?.bounds ?? .zero
            let minX = VTGoToMapOverlay.radius
            let minY = VTGoToMapOverlay.radius
            let maxX = bounds.maxX - minX
            let maxY = bounds.maxY - minY
            overlayModel.centerPoint = CGPoint(
                x: min(max(point.x - offset.x, minX), maxX),
                y: min(max(point.y - offset.y, minY), maxY)
            )
        }

        configure(with: overlayModel)
    }

    @discardableResult
    override func translate(by delta: CGPoint, within bounds: CGRect?) -> Bool {
        guard let overlayModel else { return false }

        let proposedPoint = overlayModel.centerPoint.offsetBy(dx: delta.x, dy: delta.y)
        let boundedPoint = proposedPoint.clamped(to: bounds)
        guard boundedPoint != overlayModel.centerPoint else { return false }

        overlayModel.centerPoint = boundedPoint
        configure(with: overlayModel)
        return true
    }

    override func endInteraction() {
        interaction = nil
    }
}
