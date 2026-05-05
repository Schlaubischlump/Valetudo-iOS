//
//  VTLineMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 02.05.26.
//
import CoreGraphics
import UIKit

@MainActor
/// Editable map overlay that represents a line segment with optional endpoint constraints.
class VTLineMapOverlay: VTMapOverlay {
    /// Defines how a freshly inserted line should be positioned around the insertion point.
    enum InsertionBehavior {
        case keepCurrentCenter
        case horizontal(length: CGFloat)
    }

    /// Visual and insertion configuration shared with the backing layer.
    struct Style {
        let bodyColor: CGColor
        let strokeColor: CGColor?
        let thickness: CGFloat
        let strokeWidth: CGFloat
        let insertionBehavior: InsertionBehavior
    }

    var startPoint: CGPoint
    var endPoint: CGPoint

    private let minimumLength: CGFloat
    private let style: Style

    // MARK: - Init

    /// Creates a line overlay with the provided geometry and presentation style.
    init(
        startPoint: CGPoint,
        endPoint: CGPoint,
        minimumLength: CGFloat,
        style: Style,
        id: UUID = UUID(),
        isSelected: Bool = false
    ) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.minimumLength = minimumLength
        self.style = style
        super.init(id: id, isSelected: isSelected)
    }

    // MARK: - Layer Configuration

    /// Creates the backing layer used to render and interact with this line overlay.
    override func makeLayer() -> VTMapOverlayLayer {
        VTLineMapOverlayLayer(overlayID: id)
    }

    /// Applies the current line geometry and interaction callbacks to the backing layer.
    override func configure(layer: VTMapOverlayLayer) {
        guard let layer = layer as? VTLineMapOverlayLayer else {
            assertionFailure("Expected VTLineMapOverlayLayer")
            return
        }
        layer.configure(
            with: lineLayerConfiguration(),
            callbacks: .init(
                refresh: { [self] in lineLayerConfiguration() },
                move: { [self] point, offsetToStart, offsetToEnd, bounds in
                    moveLine(to: point, offsetToStart: offsetToStart, offsetToEnd: offsetToEnd, within: bounds)
                },
                dragStart: { [self] point, fixedEnd, bounds in
                    dragLineStart(to: point, fixedEnd: fixedEnd, within: bounds)
                },
                dragEnd: { [self] point, fixedStart, bounds in
                    dragLineEnd(to: point, fixedStart: fixedStart, within: bounds)
                },
                translate: { [self] delta, bounds in
                    translateLine(by: delta, within: bounds)
                }
            )
        )
    }

    // MARK: - Insertion

    /// Repositions the line before insertion according to the configured insertion behavior.
    override func prepareForInsertion(at point: CGPoint) {
        switch style.insertionBehavior {
        case .keepCurrentCenter:
            let midpoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
            let translation = CGPoint(x: point.x - midpoint.x, y: point.y - midpoint.y)
            startPoint = startPoint.offsetBy(dx: translation.x, dy: translation.y)
            endPoint = endPoint.offsetBy(dx: translation.x, dy: translation.y)
        case let .horizontal(length):
            startPoint = CGPoint(x: point.x - length / 2, y: point.y)
            endPoint = CGPoint(x: point.x + length / 2, y: point.y)
        }
    }

    // MARK: - Geometry

    /// Builds the immutable configuration snapshot consumed by the overlay layer.
    func lineLayerConfiguration() -> VTLineMapOverlayLayer.Configuration {
        .init(
            isSelected: isSelected,
            startPoint: startPoint,
            endPoint: endPoint,
            bodyColor: style.bodyColor,
            strokeColor: style.strokeColor,
            bodyWidth: style.thickness,
            strokeWidth: style.strokeWidth
        )
    }

    /// Moves the full line while preserving the pointer's relative offset to both endpoints.
    func moveLine(to point: CGPoint, offsetToStart: CGPoint, offsetToEnd: CGPoint, within bounds: CGRect?) {
        let proposedStart = CGPoint(x: point.x - offsetToStart.x, y: point.y - offsetToStart.y)
        let proposedEnd = CGPoint(x: point.x - offsetToEnd.x, y: point.y - offsetToEnd.y)
        let translation = CGPoint.translationToFit(start: proposedStart, end: proposedEnd, within: bounds)
        startPoint = proposedStart.offsetBy(dx: translation.x, dy: translation.y)
        endPoint = proposedEnd.offsetBy(dx: translation.x, dy: translation.y)
    }

    /// Drags the start endpoint while keeping the opposite endpoint fixed.
    func dragLineStart(to point: CGPoint, fixedEnd: CGPoint, within bounds: CGRect?) {
        endPoint = fixedEnd
        updateKeepingEnd(startPoint: point.clamped(to: bounds))
        startPoint = startPoint.clamped(to: bounds)
    }

    /// Drags the end endpoint while keeping the opposite endpoint fixed.
    func dragLineEnd(to point: CGPoint, fixedStart: CGPoint, within bounds: CGRect?) {
        startPoint = fixedStart
        updateKeepingStart(endPoint: point.clamped(to: bounds))
        endPoint = endPoint.clamped(to: bounds)
    }

    /// Translates the full line by the provided delta, clamping both endpoints into bounds if needed.
    func translateLine(by delta: CGPoint, within bounds: CGRect?) -> Bool {
        let proposedStart = startPoint.offsetBy(dx: delta.x, dy: delta.y)
        let proposedEnd = endPoint.offsetBy(dx: delta.x, dy: delta.y)
        let translation = CGPoint.translationToFit(start: proposedStart, end: proposedEnd, within: bounds)
        let boundedStart = proposedStart.offsetBy(dx: translation.x, dy: translation.y)
        let boundedEnd = proposedEnd.offsetBy(dx: translation.x, dy: translation.y)

        guard boundedStart != startPoint || boundedEnd != endPoint else { return false }

        startPoint = boundedStart
        endPoint = boundedEnd
        return true
    }

    /// Updates the end endpoint while enforcing the minimum line length from the fixed start point.
    func updateKeepingStart(endPoint: CGPoint) {
        let delta = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let length = hypot(delta.x, delta.y)
        guard length > 0 else { return }

        if length < minimumLength {
            // Project the requested endpoint back onto the same direction vector so the line keeps
            // its angle while being stretched to the minimum allowed length.
            let scale = minimumLength / length
            self.endPoint = CGPoint(x: startPoint.x + delta.x * scale, y: startPoint.y + delta.y * scale)
        } else {
            self.endPoint = endPoint
        }
    }

    /// Updates the start endpoint while enforcing the minimum line length from the fixed end point.
    func updateKeepingEnd(startPoint: CGPoint) {
        let delta = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let length = hypot(delta.x, delta.y)
        guard length > 0 else { return }

        if length < minimumLength {
            // Mirror the same minimum-length enforcement used for the end handle, but anchored to
            // the current end point.
            let scale = minimumLength / length
            self.startPoint = CGPoint(x: endPoint.x - delta.x * scale, y: endPoint.y - delta.y * scale)
        } else {
            self.startPoint = startPoint
        }
    }
}
