//
//  VTGoToMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 04.05.26.
//
import Foundation

/// Crosshair-style transient overlay used to place and move a go-to target on the map.
@MainActor
final class VTGoToMapOverlay: VTMapOverlay {
    static let radius: CGFloat = 18.0

    /// Overlay-space center point of the go-to crosshair.
    var centerPoint: CGPoint

    /// Creates the transient go-to target overlay at the given overlay-space point.
    init(centerPoint: CGPoint) {
        self.centerPoint = centerPoint
        super.init()
    }

    override func makeLayer() -> VTMapOverlayLayer {
        VTGoToMapOverlayLayer(overlayID: id)
    }

    override func configure(layer: VTMapOverlayLayer) {
        guard let layer = layer as? VTGoToMapOverlayLayer else { return }
        layer.configure(with: self)
    }

    override func prepareForInsertion(at point: CGPoint) {
        if centerPoint == .zero {
            centerPoint = point
        }
    }

    /// Uses a circular hit frame so taps and drags are forgiving around the visual crosshair.
    var hitFrame: CGRect {
        CGRect(
            x: centerPoint.x - Self.radius,
            y: centerPoint.y - Self.radius,
            width: Self.radius * 2,
            height: Self.radius * 2
        ).insetBy(dx: -10, dy: -10)
    }
}
