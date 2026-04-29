//
//  VTMapView.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

private let pad = 10.0

/// Displays a rendered robot map, supports segment selection, and hosts transient editing overlays.
@MainActor
class VTMapView: UIView, UIGestureRecognizerDelegate {
    /// The currently displayed map snapshot.
    private(set) var data: VTMapData

    /// Root Core Animation layer containing the rendered map content.
    private var mapLayer: CALayer

    /// Segment layers currently highlighted as selected.
    private(set) var selectedLayers: Set<VTLayer> = []

    /// Dedicated layer that hosts transient editing overlays above the map content.
    private let overlayLayer = CALayer()

    /// Coordinates transient overlay models, selection, and interactions for `overlayLayer`.
    private let overlayController = VTMapOverlayController()

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    private lazy var overlayPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleOverlayPan(_:)))

    /// Whether no-go areas should be omitted from the rendered map.
    var hideNoGoAreas: Bool = true

    /// Asks the host whether a segment selection change should be allowed.
    var shouldChangeLayerSelection: ((VTLayer, Bool) async -> Bool)?

    /// Informs the host after a segment selection change was applied.
    var didChangeLayerSelection: ((VTLayer, Bool) async -> Void)?

    /// Handles taps on map entities and receives the tapped entity plus its position in view space.
    ///
    /// Return `true` when the tap was fully handled so the map view stops hit-testing lower layers
    /// or falling through to segment selection for the same gesture.
    var onEntityClicked: ((VTEntity, CGPoint) async -> Bool)?

    /// Creates a map view sized to fit the provided map data within the given frame.
    init(frame: CGRect, data: VTMapData) {
        self.data = data

        let scale = UIScreen.current?.scale ?? kDefaultScale
        let fittingFrame = frame.size.insetBy(dx: pad, dy: pad)
        mapLayer = data.toLayer(fitting: fittingFrame, screenScale: scale, hideNoGoAreas: hideNoGoAreas)

        // use the size of the mapLayer to get a fitting size for the parent
        let size = mapLayer.frame.size

        super.init(frame: CGRect(origin: frame.origin, size: size.insetBy(dx: -pad, dy: -pad)))

        mapLayer.position = CGPoint(x: pad / 2.0, y: pad / 2.0)
        layer.addSublayer(mapLayer)
        attachOverlayLayer()

        configureGestures()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Clears the current segment selection without triggering external callbacks.
    func clearSelection() async {
        for layer in selectedLayers {
            await toggleLayerSelection(for: layer, in: shapeLayerForVTLayer(vtLayer: layer)!, triggerCallback: false)
        }
    }

    /// Rebuilds the rendered map from a fresh snapshot while preserving the current view transform.
    func updateData(data: VTMapData) async {
        self.data = data
        let scale = UIScreen.current?.scale ?? kDefaultScale
        let fittingFrame = frame.size.insetBy(dx: pad, dy: pad)
        let newMapLayer = data.toLayer(fitting: fittingFrame, screenScale: scale, hideNoGoAreas: hideNoGoAreas)
        newMapLayer.position = mapLayer.position
        let transform = mapLayer.transform
        mapLayer.removeFromSuperlayer()
        mapLayer = newMapLayer
        mapLayer.transform = transform
        layer.addSublayer(mapLayer)
        attachOverlayLayer()
        selectedLayers = []
    }

    // MARK: - Overlay

    /// Replaces the transient overlays rendered above the map and optionally selects one of them.
    func setTransientOverlays(_ overlays: [VTMapOverlay], selectedOverlayID: UUID? = nil) {
        overlayController.setOverlays(overlays, selectedOverlayID: selectedOverlayID)
    }

    /// Inserts a single transient overlay and positions it at the map center by default.
    @discardableResult
    func addOverlay(_ overlay: VTMapOverlay, selected: Bool = true) -> UUID {
        overlay.prepareForInsertion(at: overlayCenterPoint)
        overlayController.addOverlay(overlay, selected: selected)
        return overlay.id
    }

    /// Clears all transient overlays from the map.
    func clearTransientOverlays() {
        overlayController.clear()
    }

    /// Returns the current overlay model for the given identifier.
    func overlay(withID id: UUID) -> VTMapOverlay? {
        overlayController.overlay(withID: id)
    }

    /// Converts an overlay-space point into the raw map coordinate system used by `VTMapData`.
    func mapCoordinate(fromOverlayPoint point: CGPoint) -> CGPoint {
        CGPoint(x: point.x + data.boundingRect.minX, y: point.y + data.boundingRect.minY)
    }

    /// Converts a raw `VTMapData` coordinate into the overlay-space coordinate system.
    func overlayPoint(fromMapCoordinate point: CGPoint) -> CGPoint {
        CGPoint(x: point.x - data.boundingRect.minX, y: point.y - data.boundingRect.minY)
    }

    /// Center point used when inserting new overlays without a caller-provided position.
    private var overlayCenterPoint: CGPoint {
        CGPoint(x: data.boundingRect.width / 2, y: data.boundingRect.height / 2)
    }

    /// Installs the generic overlay container above the map content so transient editing geometry
    /// shares the same scale and pan behavior as the persisted map.
    private func attachOverlayLayer() {
        overlayLayer.removeFromSuperlayer()
        overlayLayer.frame = mapLayer.bounds
        overlayLayer.anchorPoint = .zero
        overlayLayer.position = .zero
        overlayLayer.contentsScale = mapLayer.contentsScale
        mapLayer.addSublayer(overlayLayer)
        overlayController.attach(to: overlayLayer)
    }

    // MARK: - Layer selection

    /// Selects a segment layer programmatically.
    func select(layer: VTLayer) async {
        guard !selectedLayers.contains(layer), let shapeLayer = shapeLayerForVTLayer(vtLayer: layer) else { return }
        await toggleLayerSelection(for: layer, in: shapeLayer, triggerCallback: false)
    }

    /// Deselects a segment layer programmatically.
    func deselect(layer: VTLayer) async {
        guard selectedLayers.contains(layer), let shapeLayer = shapeLayerForVTLayer(vtLayer: layer) else { return }
        await toggleLayerSelection(for: layer, in: shapeLayer, triggerCallback: false)
    }

    private func shapeLayerForVTLayer(vtLayer: VTLayer) -> VTLayerShapeLayer? {
        mapLayer.sublayers?
            .compactMap { $0 as? VTLayerShapeLayer }
            .first(where: { vtLayer == $0.data })
    }

    @discardableResult private func toggleLayerSelection(
        for vtLayer: VTLayer,
        in shapeLayer: any VTShapeLayerProtocol,
        triggerCallback: Bool
    ) async -> Bool {
        guard vtLayer.type == .segment else { return false }

        let isSelected: Bool = selectedLayers.contains(vtLayer)
        var updateSelection = false

        if triggerCallback {
            updateSelection = await (shouldChangeLayerSelection?(vtLayer, isSelected) ?? true)
        } else {
            updateSelection = true
        }

        guard updateSelection else { return false }

        if isSelected {
            selectedLayers.remove(vtLayer)
            shapeLayer.fillColor = vtLayer.fillColor
        } else {
            selectedLayers.insert(vtLayer)
            shapeLayer.fillColor = vtLayer.fillColor?.darker(by: 0.5)
        }

        if triggerCallback {
            await didChangeLayerSelection?(vtLayer, !isSelected)
        }
        return true
    }

    // MARK: - Gesture handling

    /// Installs the recognizers used for map taps and overlay drag interactions.
    private func configureGestures() {
        tapGestureRecognizer.delegate = self
        overlayPanGestureRecognizer.delegate = self

        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(overlayPanGestureRecognizer)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        Task { [weak self] in
            await self?.handleTap(atLocation: point)
        }
    }

    /// Handles taps by first offering them to overlays, then falling back to entities and segments.
    private func handleTap(atLocation point: CGPoint) async {
        let mapPoint = layer.convert(point, to: mapLayer)

        if overlayController.selectOverlay(at: mapPoint) {
            return
        }

        guard let shapeLayers = mapLayer.sublayers?
            .compactMap({ $0 as? (any VTShapeLayerProtocol) })
            .reversed() // reverse to make sure we iterate the topmost layer first
        else { return }

        // figure out which layer was selected
        for shapeLayer in shapeLayers {
            let pathPoint = mapLayer.convert(mapPoint, to: shapeLayer)
            let pointInPath = shapeLayer.contains(pathPoint)
            guard pointInPath else { continue }

            if let vtEntity = shapeLayer.data as? VTEntity {
                let position = mapLayer.convert(shapeLayer.center, to: layer)
                if await (onEntityClicked?(vtEntity, position) ?? false) {
                    break
                }
            }

            if let vtLayer = shapeLayer.data as? VTLayer {
                if await (toggleLayerSelection(for: vtLayer, in: shapeLayer, triggerCallback: true)) {
                    break
                }
            }
        }
    }

    /// Forwards pan interactions in map coordinates to the active transient overlay controller.
    @objc private func handleOverlayPan(_ gesture: UIPanGestureRecognizer) {
        let mapPoint = layer.convert(gesture.location(in: self), to: mapLayer)

        switch gesture.state {
        case .began:
            overlayController.beginInteraction(at: mapPoint)
        case .changed:
            overlayController.updateInteraction(to: mapPoint)
        case .ended, .cancelled, .failed:
            overlayController.endInteraction()
        default:
            break
        }
    }

    /// Limits the overlay pan recognizer to touches that actually start on an interactive overlay.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case overlayPanGestureRecognizer:
            let location = gestureRecognizer.location(in: self)
            let mapPoint = layer.convert(location, to: mapLayer)
            return overlayController.canBeginInteraction(at: mapPoint)
        default:
            return true
        }
    }
}
