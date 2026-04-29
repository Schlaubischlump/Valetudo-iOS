//
//  VTLineMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 29.04.26.
//
import Foundation
import UIKit

/// Transient line overlay used for split guides and future wall placement tools.
@MainActor
final class VTSplitLineMapOverlay: VTMapOverlay {
    private static let minimumLength: CGFloat = 28.0

    var center: CGPoint
    var angle: CGFloat
    var length: CGFloat
    var thickness: CGFloat

    private let fillColor: UIColor
    private let strokeColor: UIColor
    private let dashPattern: [NSNumber]
    private let strokeWidth: CGFloat
    private let hitTestThickness: CGFloat

    init(
        center: CGPoint,
        angle: CGFloat = 0.0,
        length: CGFloat,
        thickness: CGFloat,
        fillColor: UIColor = .white,
        strokeColor: UIColor = .black,
        dashPattern: [NSNumber] = [8, 6],
        strokeWidth: CGFloat = 2.0,
        hitTestThickness: CGFloat = 28.0
    ) {
        self.center = center
        self.angle = angle
        self.length = length
        self.thickness = thickness
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.dashPattern = dashPattern
        self.strokeWidth = strokeWidth
        self.hitTestThickness = hitTestThickness
        super.init()
    }

    override func makeLayer() -> VTMapOverlayLayer {
        VTSplitLineMapOverlayLayer(overlayID: id)
    }

    override func configure(layer: VTMapOverlayLayer) {
        guard let layer = layer as? VTSplitLineMapOverlayLayer else {
            assertionFailure("Expected VTSplitLineMapOverlayLayer")
            return
        }
        layer.configure(with: self)
    }

    override func prepareForInsertion(at point: CGPoint) {
        center = point
    }

    /// Produces a capsule-like line centered at the origin, then rotates and translates it into
    /// map space so the overlay scales together with the map layer.
    fileprivate func makePath(thickness: CGFloat) -> UIBezierPath {
        let roundedRect = CGRect(
            x: -length / 2,
            y: -thickness / 2,
            width: length,
            height: thickness
        )
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: thickness / 2)
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: center.x, y: center.y))
        return path
    }

    var startPoint: CGPoint {
        CGPoint(
            x: center.x - cos(angle) * length / 2,
            y: center.y - sin(angle) * length / 2
        )
    }

    var endPoint: CGPoint {
        CGPoint(
            x: center.x + cos(angle) * length / 2,
            y: center.y + sin(angle) * length / 2
        )
    }

    fileprivate func updateLine(start: CGPoint, end: CGPoint) {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let distance = hypot(deltaX, deltaY)

        if distance > 0.0 {
            length = max(Self.minimumLength, distance)
            angle = atan2(deltaY, deltaX)
            center = CGPoint(
                x: start.x + cos(angle) * length / 2,
                y: start.y + sin(angle) * length / 2
            )
        }
    }

    fileprivate var fillColorValue: CGColor {
        fillColor.cgColor
    }

    fileprivate var strokeColorValue: CGColor {
        strokeColor.cgColor
    }

    fileprivate var dashPatternValue: [NSNumber] {
        dashPattern
    }

    fileprivate var strokeWidthValue: CGFloat {
        strokeWidth
    }

    fileprivate var hitTestThicknessValue: CGFloat {
        hitTestThickness
    }
}

/// Shape layer that owns split-line interaction details, including endpoint dragging.
@MainActor
final class VTSplitLineMapOverlayLayer: VTMapOverlayLayer {
    private enum Interaction {
        case move(offsetFromCenter: CGPoint)
        case dragStart(fixedEnd: CGPoint)
        case dragEnd(fixedStart: CGPoint)
    }

    private let startHandleLayer = CAShapeLayer()
    private let endHandleLayer = CAShapeLayer()

    private var splitOverlay: VTSplitLineMapOverlay?
    private var interaction: Interaction?
    private var startHandleHitPath: CGPath?
    private var endHandleHitPath: CGPath?

    override init(overlayID: UUID) {
        super.init(overlayID: overlayID)
        addSublayer(startHandleLayer)
        addSublayer(endHandleLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Rebuilds the line and handle visuals from the latest overlay model state.
    func configure(with overlay: VTSplitLineMapOverlay) {
        splitOverlay = overlay
        isOverlaySelected = overlay.isSelected

        let visualPath = overlay.makePath(thickness: overlay.thickness)
        let hitPath = overlay.makePath(thickness: max(overlay.thickness, overlay.hitTestThicknessValue))

        path = visualPath.cgPath
        hitTestPath = hitPath.cgPath
        fillColor = overlay.fillColorValue
        strokeColor = overlay.strokeColorValue
        lineWidth = overlay.strokeWidthValue
        lineDashPattern = overlay.dashPatternValue
        lineCap = .round
        lineJoin = .round
        shadowColor = overlay.isSelected ? UIColor.black.cgColor : nil
        shadowOpacity = overlay.isSelected ? 0.18 : 0.0
        shadowRadius = overlay.isSelected ? 5.0 : 0.0
        shadowOffset = .zero

        configureHandleLayers(for: overlay)
    }

    override func selectionStateDidChange() {
        startHandleLayer.isHidden = !isOverlaySelected
        endHandleLayer.isHidden = !isOverlaySelected
    }

    override func containsInteractivePoint(_ point: CGPoint) -> Bool {
        if startHandleHitPath?.contains(point) == true || endHandleHitPath?.contains(point) == true {
            return true
        }
        return containsOverlayPoint(point)
    }

    @discardableResult
    override func beginInteraction(at point: CGPoint) -> Bool {
        guard let overlay = splitOverlay else { return false }

        if isOverlaySelected, startHandleHitPath?.contains(point) == true {
            interaction = .dragStart(fixedEnd: overlay.endPoint)
            return true
        }

        if isOverlaySelected, endHandleHitPath?.contains(point) == true {
            interaction = .dragEnd(fixedStart: overlay.startPoint)
            return true
        }

        guard containsInteractivePoint(point) else { return false }
        interaction = .move(offsetFromCenter: CGPoint(x: overlay.center.x - point.x, y: overlay.center.y - point.y))
        return true
    }

    override func updateInteraction(to point: CGPoint) {
        guard let overlay = splitOverlay, let interaction else { return }

        switch interaction {
        case let .move(offsetFromCenter):
            overlay.center = CGPoint(x: point.x + offsetFromCenter.x, y: point.y + offsetFromCenter.y)
        case let .dragStart(fixedEnd):
            overlay.updateLine(start: point, end: fixedEnd)
        case let .dragEnd(fixedStart):
            overlay.updateLine(start: fixedStart, end: point)
        }

        configure(with: overlay)
    }

    override func endInteraction() {
        interaction = nil
    }

    /// Draws two endpoint handles so the user can discover and grab the rotation anchors.
    private func configureHandleLayers(for overlay: VTSplitLineMapOverlay) {
        let visibleRadius = max(overlay.thickness * 0.6, 7.0)
        let hitRadius = visibleRadius + 18.0

        configureHandleLayer(startHandleLayer, center: overlay.startPoint, visibleRadius: visibleRadius)
        configureHandleLayer(endHandleLayer, center: overlay.endPoint, visibleRadius: visibleRadius)

        startHandleHitPath = UIBezierPath(
            ovalIn: CGRect(
                x: overlay.startPoint.x - hitRadius,
                y: overlay.startPoint.y - hitRadius,
                width: hitRadius * 2,
                height: hitRadius * 2
            )
        ).cgPath
        endHandleHitPath = UIBezierPath(
            ovalIn: CGRect(
                x: overlay.endPoint.x - hitRadius,
                y: overlay.endPoint.y - hitRadius,
                width: hitRadius * 2,
                height: hitRadius * 2
            )
        ).cgPath

        selectionStateDidChange()
    }

    private func configureHandleLayer(_ handleLayer: CAShapeLayer, center: CGPoint, visibleRadius: CGFloat) {
        handleLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: center.x - visibleRadius,
                y: center.y - visibleRadius,
                width: visibleRadius * 2,
                height: visibleRadius * 2
            )
        ).cgPath
        handleLayer.fillColor = UIColor.white.cgColor
        handleLayer.strokeColor = UIColor.black.cgColor
        handleLayer.lineWidth = 2.0
        handleLayer.isHidden = !isOverlaySelected
    }
}
