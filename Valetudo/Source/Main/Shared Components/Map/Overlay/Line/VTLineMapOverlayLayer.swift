//
//  VTLineMapOverlayLayer.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//
import CoreGraphics
import QuartzCore
import UIKit

@MainActor
final class VTLineMapOverlayLayer: VTMapOverlayLayer {
    struct Configuration {
        let isSelected: Bool
        let startPoint: CGPoint
        let endPoint: CGPoint
        let bodyColor: CGColor
        let strokeColor: CGColor?
        let bodyWidth: CGFloat
        let strokeWidth: CGFloat
    }

    struct Callbacks {
        let refresh: () -> Configuration
        let move: (_ point: CGPoint, _ offsetToStart: CGPoint, _ offsetToEnd: CGPoint, _ bounds: CGRect?) -> Void
        let dragStart: (_ point: CGPoint, _ fixedEnd: CGPoint, _ bounds: CGRect?) -> Void
        let dragEnd: (_ point: CGPoint, _ fixedStart: CGPoint, _ bounds: CGRect?) -> Void
        let translate: (_ delta: CGPoint, _ bounds: CGRect?) -> Bool
    }

    private enum HandleTarget {
        case start
        case end
    }

    private enum Interaction {
        case move(offsetToStart: CGPoint, offsetToEnd: CGPoint)
        case dragStart(fixedEnd: CGPoint)
        case dragEnd(fixedStart: CGPoint)
    }

    static let minimumHandleVisibleRadius: CGFloat = 5.0
    static let minimumHandleHitRadius: CGFloat = 26.0
    static let minimumBodyHitThickness: CGFloat = 24.0

    private let bodyLayer = CAShapeLayer()
    private let startHandleLayer = CAShapeLayer()
    private let endHandleLayer = CAShapeLayer()

    private var configuration: Configuration?
    private var callbacks: Callbacks?
    private var interaction: Interaction?

    override init(overlayID: UUID) {
        super.init(overlayID: overlayID)
        configureManagedSublayers()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        MainActor.assumeIsolated { [self] in
            configureManagedSublayers()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with configuration: Configuration, callbacks: Callbacks) {
        self.configuration = configuration
        self.callbacks = callbacks
        isOverlaySelected = configuration.isSelected

        let bodyPath = roundedBodyPath(
            start: configuration.startPoint,
            end: configuration.endPoint,
            width: configuration.bodyWidth
        )
        let interactivePath = makeHitTestPath(
            start: configuration.startPoint,
            end: configuration.endPoint,
            bodyWidth: configuration.bodyWidth,
            strokeWidth: configuration.strokeWidth
        )
        let handleRadius = max(configuration.bodyWidth * 0.6, Self.minimumHandleVisibleRadius)

        hitTestPath = interactivePath
        path = nil
        fillColor = nil
        strokeColor = nil
        lineWidth = 0.0
        lineDashPattern = nil
        lineCap = .round
        lineJoin = .round

        bodyLayer.path = bodyPath
        bodyLayer.fillColor = configuration.bodyColor
        bodyLayer.lineCap = .round
        bodyLayer.lineJoin = .round

        configureHandleLayer(
            startHandleLayer,
            center: configuration.startPoint,
            visibleRadius: handleRadius,
            fillColor: configuration.bodyColor,
            strokeColor: configuration.strokeColor,
            lineWidth: configuration.strokeWidth
        )
        configureHandleLayer(
            endHandleLayer,
            center: configuration.endPoint,
            visibleRadius: handleRadius,
            fillColor: configuration.bodyColor,
            strokeColor: configuration.strokeColor,
            lineWidth: configuration.strokeWidth
        )

        selectionStateDidChange()
    }

    override func selectionStateDidChange() {
        bodyLayer.strokeColor = isOverlaySelected ? configuration?.strokeColor : nil
        bodyLayer.lineWidth = isOverlaySelected ? (configuration?.strokeWidth ?? 0.0) : 0.0
        bodyLayer.lineDashPattern = isOverlaySelected && configuration?.strokeColor != nil ? [5, 6] : nil
        startHandleLayer.isHidden = !isOverlaySelected
        endHandleLayer.isHidden = !isOverlaySelected
    }

    override func containsInteractivePoint(_ point: CGPoint) -> Bool {
        nearestHandle(to: point) != nil || containsOverlayPoint(point)
    }

    @discardableResult
    override func beginInteraction(at point: CGPoint) -> Bool {
        guard let configuration else { return false }

        if isOverlaySelected, nearestHandle(to: point) == .start {
            interaction = .dragStart(fixedEnd: configuration.endPoint)
            return true
        }

        if isOverlaySelected, nearestHandle(to: point) == .end {
            interaction = .dragEnd(fixedStart: configuration.startPoint)
            return true
        }

        guard containsInteractivePoint(point) else { return false }
        interaction = .move(
            offsetToStart: CGPoint(x: point.x - configuration.startPoint.x, y: point.y - configuration.startPoint.y),
            offsetToEnd: CGPoint(x: point.x - configuration.endPoint.x, y: point.y - configuration.endPoint.y)
        )
        return true
    }

    override func updateInteraction(to point: CGPoint) {
        guard let callbacks, let interaction else { return }
        let containerBounds = superlayer?.bounds

        switch interaction {
        case let .move(offsetToStart, offsetToEnd):
            callbacks.move(point, offsetToStart, offsetToEnd, containerBounds)
        case let .dragStart(fixedEnd):
            callbacks.dragStart(point, fixedEnd, containerBounds)
        case let .dragEnd(fixedStart):
            callbacks.dragEnd(point, fixedStart, containerBounds)
        }

        configure(with: callbacks.refresh(), callbacks: callbacks)
    }

    @discardableResult
    override func translate(by delta: CGPoint, within bounds: CGRect?) -> Bool {
        guard let callbacks else { return false }
        let changed = callbacks.translate(delta, bounds)
        guard changed else { return false }
        configure(with: callbacks.refresh(), callbacks: callbacks)
        return true
    }

    override func endInteraction() {
        interaction = nil
    }

    private func configureHandleLayer(
        _ handleLayer: CAShapeLayer,
        center: CGPoint,
        visibleRadius: CGFloat,
        fillColor: CGColor,
        strokeColor: CGColor?,
        lineWidth: CGFloat
    ) {
        handleLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: center.x - visibleRadius,
                y: center.y - visibleRadius,
                width: visibleRadius * 2,
                height: visibleRadius * 2
            )
        ).cgPath
        handleLayer.fillColor = fillColor
        handleLayer.strokeColor = strokeColor
        handleLayer.lineWidth = strokeColor == nil ? 0.0 : lineWidth
    }

    private func nearestHandle(to point: CGPoint) -> HandleTarget? {
        guard let configuration else { return nil }

        let startDistance = point.distance(to: configuration.startPoint)
        let endDistance = point.distance(to: configuration.endPoint)
        let minDistance = min(startDistance, endDistance)

        let visibleRadius = max(configuration.bodyWidth * 0.6, Self.minimumHandleVisibleRadius)
        #if os(macOS) || targetEnvironment(macCatalyst)
            let hitRadius = visibleRadius
        #else
            let hitRadius = max(visibleRadius + 18.0, Self.minimumHandleHitRadius)
        #endif
        guard minDistance <= hitRadius else { return nil }
        return startDistance <= endDistance ? .start : .end
    }

    private func roundedBodyPath(start: CGPoint, end: CGPoint, width: CGFloat) -> CGPath {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let angle = atan2(deltaY, deltaX)
        let length = hypot(deltaX, deltaY)
        let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        let roundedRect = CGRect(
            x: -length / 2,
            y: -width / 2,
            width: length,
            height: width
        )
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: width / 2)
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: center.x, y: center.y))
        return path.cgPath
    }

    private func makeHitTestPath(start: CGPoint, end: CGPoint, bodyWidth: CGFloat, strokeWidth: CGFloat) -> CGPath {
        #if os(macOS) || targetEnvironment(macCatalyst)
            let hitThickness = max(bodyWidth, strokeWidth)
        #else
            let hitThickness = max(bodyWidth, strokeWidth, Self.minimumBodyHitThickness)
        #endif
        return roundedBodyPath(start: start, end: end, width: hitThickness)
    }

    private func configureManagedSublayers() {
        addSublayer(bodyLayer)
        addSublayer(startHandleLayer)
        addSublayer(endHandleLayer)
    }
}
