//
//  VTMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 29.09.25.
//
import Foundation

/// Describes a transient overlay rendered in map coordinates above the persisted map content.
///
/// Overlays are intentionally kept separate from backend state so editing tools can create,
/// manipulate, and discard geometry locally before committing it to the server.
@MainActor
class VTMapOverlay {
    /// Stable identity used to preserve selection and reuse matching layers across redraws.
    let id: UUID

    /// Whether the overlay is currently selected for interaction.
    var isSelected: Bool

    /// Whether the overlay may be deselected by general map taps or explicit clear-selection flows.
    var allowsDeselection: Bool {
        true
    }

    init(id: UUID = UUID(), isSelected: Bool = false) {
        self.id = id
        self.isSelected = isSelected
    }

    /// Creates the concrete layer responsible for rendering and interaction.
    func makeLayer() -> VTMapOverlayLayer {
        VTMapOverlayLayer(overlayID: id)
    }

    /// Builds or refreshes the layer contents for the current overlay state.
    func configure(layer _: VTMapOverlayLayer) {
        fatalError("Subclasses must implement configure(layer:)")
    }

    /// Gives overlays a chance to choose an initial position when inserted into a map.
    ///
    /// The point is expressed in the overlay's internal coordinate space, which for the current
    /// implementation matches the unscaled map layer coordinate system.
    func prepareForInsertion(at _: CGPoint) {}
}
