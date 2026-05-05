//
//  VTResizableRectangularMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//
import CoreGraphics
import QuartzCore
import UIKit

@MainActor
class VTResizableRectangularMapOverlay: VTMapOverlay {
    /// Implemented for future proofing. We might want to add more handle types.
    enum Handle {
        case resize
    }

    static let minimumSideLength: CGFloat = 20.0

    private static let defaultSize = CGSize(width: 48, height: 48)
    fileprivate static let controlSize = CGSize(width: 20, height: 20)
    fileprivate static let controlHitInset: CGFloat = 10.0

    var rect: CGRect
    let strokeColor: UIColor
    let fillColor: UIColor

    init(rect: CGRect, strokeColor: UIColor, fillColor: UIColor) {
        self.rect = rect.standardized
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        super.init()
    }

    override func makeLayer() -> VTMapOverlayLayer {
        VTResizableRectangularMapOverlayLayer(overlayID: id)
    }

    override func configure(layer: VTMapOverlayLayer) {
        guard let layer = layer as? VTResizableRectangularMapOverlayLayer else {
            assertionFailure("Expected VTRectangularVirtualRestrictionMapOverlayLayer")
            return
        }
        layer.configure(with: self)
    }

    override func prepareForInsertion(at point: CGPoint) {
        rect = CGRect(
            x: point.x - Self.defaultSize.width / 2,
            y: point.y - Self.defaultSize.height / 2,
            width: Self.defaultSize.width,
            height: Self.defaultSize.height
        )
    }

    func updateRect(origin: CGPoint, size: CGSize) {
        rect = CGRect(
            origin: origin,
            size: CGSize(
                width: max(Self.minimumSideLength, size.width),
                height: max(Self.minimumSideLength, size.height)
            )
        ).standardized
    }

    var resizeControlFrame: CGRect {
        CGRect(
            x: rect.maxX - Self.controlSize.width / 2,
            y: rect.maxY - Self.controlSize.height / 2,
            width: Self.controlSize.width,
            height: Self.controlSize.height
        )
    }

    var hitTestRect: CGRect {
        #if os(macOS) || targetEnvironment(macCatalyst)
            rect
        #else
            rect.insetBy(dx: -12, dy: -12)
        #endif
    }

    func handle(at point: CGPoint) -> Handle? {
        let resizeHitFrame = resizeControlFrame.insetBy(dx: -Self.controlHitInset, dy: -Self.controlHitInset)
        if resizeHitFrame.contains(point) {
            return .resize
        }

        return nil
    }
}
