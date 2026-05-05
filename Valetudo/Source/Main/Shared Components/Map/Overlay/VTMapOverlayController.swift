//
//  VTMapOverlayController.swift
//  Valetudo
//
//  Created by David Klopp on 29.09.25.
//
import CoreGraphics
import Foundation
import QuartzCore

/// Coordinates transient overlay model state, backing layers, selection, and active interactions.
///
/// `VTMapView` owns the actual map layer tree and gesture recognizers, while this controller owns
/// editor-only overlay behavior layered on top of that map.
@MainActor
final class VTMapOverlayController {
    private weak var overlayContainerLayer: CALayer?

    private var overlays: [UUID: VTMapOverlay] = [:]
    private var overlayLayers: [UUID: VTMapOverlayLayer] = [:]
    private var selectedOverlayID: UUID?
    private weak var activeOverlayInteractionLayer: VTMapOverlayLayer?
    var onSelectionChanged: ((UUID?) -> Void)?
    var onOverlaysDidChange: (() -> Void)?

    var allOverlays: [VTMapOverlay] {
        overlays.values.sorted { $0.id.uuidString < $1.id.uuidString }
    }

    var currentSelectedOverlayID: UUID? {
        selectedOverlayID
    }

    /// Attaches the controller to the current overlay container layer.
    ///
    /// `VTMapView` may recreate its map layer on refresh, so the controller needs a way to rebind
    /// to the fresh container and then resync the current overlay layers.
    func attach(to overlayContainerLayer: CALayer) {
        self.overlayContainerLayer = overlayContainerLayer
        syncLayers()
    }

    /// Replaces the transient overlay models and optionally selects one of them.
    func setOverlays(_ overlays: [VTMapOverlay], selectedOverlayID: UUID? = nil) {
        self.overlays = Dictionary(uniqueKeysWithValues: overlays.map { ($0.id, $0) })
        updateSelectedOverlay(id: selectedOverlayID)
        syncLayers()
    }

    /// Inserts a single overlay into the managed collection and optionally selects it.
    func addOverlay(_ overlay: VTMapOverlay, selected: Bool = true) {
        overlays[overlay.id] = overlay
        if selected {
            updateSelectedOverlay(id: overlay.id)
        }
        syncLayers()
        onOverlaysDidChange?()
    }

    /// Removes all overlays and clears any active interaction state.
    func clear() {
        overlays.removeAll()
        for value in overlayLayers.values {
            value.prepareForRemoval()
            value.removeFromSuperlayer()
        }
        overlayLayers.removeAll()
        selectedOverlayID = nil
        activeOverlayInteractionLayer = nil
        onSelectionChanged?(nil)
    }

    /// Handles a tap on the topmost overlay under the given point.
    @discardableResult
    func handleTap(at point: CGPoint) -> Bool {
        guard let hitLayer = overlay(at: point) else { return false }

        switch hitLayer.tapAction(at: point) {
        case .none:
            return false
        case .select:
            updateSelectedOverlay(id: hitLayer.overlayID)
            syncLayers()
            return true
        }
    }

    /// Returns whether any overlay can begin interaction at the given point.
    func canBeginInteraction(at point: CGPoint) -> Bool {
        overlay(at: point) != nil
    }

    /// Starts an overlay interaction sequence at the given point.
    func beginInteraction(at point: CGPoint) {
        guard let hitLayer = overlay(at: point) else { return }
        updateSelectedOverlay(id: hitLayer.overlayID)
        syncLayers()
        guard let selectedLayer = overlayLayers[hitLayer.overlayID],
              selectedLayer.beginInteraction(at: point)
        else { return }
        activeOverlayInteractionLayer = selectedLayer
    }

    /// Updates the currently active overlay interaction, if any.
    func updateInteraction(to point: CGPoint) {
        // Don't allow moving an overlay outside the map bounds
        let boundedPoint = point.clamped(to: overlayContainerLayer?.bounds)
        activeOverlayInteractionLayer?.updateInteraction(to: boundedPoint)
        onOverlaysDidChange?()
    }

    /// Ends the active overlay interaction and clears the temporary interaction session.
    func endInteraction() {
        activeOverlayInteractionLayer?.endInteraction()
        activeOverlayInteractionLayer = nil
    }

    /// Moves the selected overlay by a fixed delta and keeps it inside the map bounds.
    @discardableResult
    func moveSelectedOverlay(by delta: CGPoint) -> Bool {
        guard let selectedOverlayID,
              let selectedLayer = overlayLayers[selectedOverlayID]
        else { return false }

        let didMove = selectedLayer.translate(by: delta, within: overlayContainerLayer?.bounds)
        if didMove {
            onOverlaysDidChange?()
        }
        return didMove
    }

    /// Returns the current overlay model for the given identifier.
    func overlay(withID id: UUID) -> VTMapOverlay? {
        overlays[id]
    }

    /// Clears the currently selected overlay, if any.
    func clearSelection() {
        guard let selectedOverlayID,
              let selectedOverlay = overlays[selectedOverlayID],
              selectedOverlay.allowsDeselection
        else { return }
        updateSelectedOverlay(id: nil)
        syncLayers()
    }

    /// Removes a single overlay from the managed collection.
    func removeOverlay(withID id: UUID) {
        overlays[id] = nil
        overlayLayers[id]?.prepareForRemoval()
        overlayLayers[id]?.removeFromSuperlayer()
        overlayLayers[id] = nil
        if selectedOverlayID == id {
            updateSelectedOverlay(id: nil)
        }
        syncLayers()
        onOverlaysDidChange?()
    }

    /// Rebuilds or reattaches backing layers after model changes or container replacement.
    private func syncLayers() {
        let overlayIDs = Set(overlays.keys)

        for staleID in overlayLayers.keys where !overlayIDs.contains(staleID) {
            overlayLayers[staleID]?.prepareForRemoval()
            overlayLayers[staleID]?.removeFromSuperlayer()
            overlayLayers.removeValue(forKey: staleID)
        }

        let orderedOverlays = overlays.values.sorted { lhs, rhs in
            switch (lhs.id == selectedOverlayID, rhs.id == selectedOverlayID) {
            case (true, false):
                false
            case (false, true):
                true
            default:
                lhs.id.uuidString < rhs.id.uuidString
            }
        }

        for overlay in orderedOverlays {
            let layer = overlayLayers[overlay.id] ?? overlay.makeLayer()
            overlayLayers[overlay.id] = layer
            layer.contentsScale = overlayContainerLayer?.contentsScale ?? 1.0
            layer.removeFromSuperlayer()
            overlayContainerLayer?.addSublayer(layer)
            overlay.configure(layer: layer)
        }
    }

    /// Updates selection state so overlays can opt into visual affordances such as shadows.
    private func updateSelectedOverlay(id: UUID?) {
        selectedOverlayID = id
        for overlay in overlays.values {
            overlay.isSelected = overlay.id == id
        }
        onSelectionChanged?(id)
    }

    /// Returns the selected overlay first when it is interactive at the touch point, otherwise
    /// falls back to the topmost overlay under that point.
    private func overlay(at point: CGPoint) -> VTMapOverlayLayer? {
        if let selectedOverlayID,
           let selectedLayer = overlayLayers[selectedOverlayID],
           selectedLayer.containsInteractivePoint(point)
        {
            return selectedLayer
        }

        return overlayContainerLayer?.sublayers?
            .compactMap { $0 as? VTMapOverlayLayer }
            .reversed()
            .first(where: { $0.containsInteractivePoint(point) })
    }
}
