//
//  VTVirtualRestrictionManagementViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

/// Manages creation, editing, and persistence of virtual walls and restricted zones on the map.
@MainActor
final class VTVirtualRestrictionManagementViewController: VTMapEditingViewController {
    private let capabilities: Set<VTCapability>
    private var hasLocalChanges = false
    private var supportedRestrictedZoneTypes: Set<VTVirtualRestrictionsZoneTypes> = []

    private var restrictionOverlays: [VTMapOverlay] {
        mapView?.transientOverlays ?? []
    }

    private var selectedRestrictionOverlayID: UUID? {
        mapView?.selectedOverlayID
    }

    /// Creates the virtual restriction editor for a robot and its advertised capabilities.
    init(client: VTAPIClientProtocol, capabilities: Set<VTCapability>) {
        self.capabilities = capabilities
        super.init(client: client)
        title = "MAP_OPTIONS_VIRTUAL_RESTRICTION_MANAGEMENT_TITLE".localized()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Loads restriction metadata once the base editor UI is ready.
    override func viewDidLoad() {
        super.viewDidLoad()

        guard capabilities.contains(.combinedVirtualRestrictions) else { return }
        Task { [weak self] in
            await self?.loadVirtualRestrictionProperties()
        }
    }

    // MARK: - Toolbar setup

    /// Returns the toolbar actions used for editing virtual restriction overlays.
    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        [
            ToolbarActionDefinition(
                title: "Remove",
                image: .virtualRestrictionDelete,
                handler: { [weak self] in
                    self?.didTapRemove()
                },
                isVisible: { [weak self] _ in
                    guard let self else { return false }
                    return !restrictionOverlays.isEmpty && selectedRestrictionOverlayID != nil
                }
            ),
            ToolbarActionDefinition(
                title: "No-Mop",
                image: .noMop,
                handler: { [weak self] in
                    self?.didTapAddNoMop()
                },
                isVisible: { [weak self, capabilities] _ in
                    guard let self, capabilities.contains(.combinedVirtualRestrictions) else { return false }
                    return supportedRestrictedZoneTypes.contains(.mop)
                }
            ),
            ToolbarActionDefinition(
                title: "No-Go",
                image: .noGo,
                handler: { [weak self] in
                    self?.didTapAddNoGo()
                },
                isVisible: { [weak self, capabilities] _ in
                    guard let self, capabilities.contains(.combinedVirtualRestrictions) else { return false }
                    return supportedRestrictedZoneTypes.contains(.regular)
                }
            ),
            ToolbarActionDefinition(
                title: "Wall",
                image: .wall,
                handler: { [weak self] in
                    self?.didTapAddWall()
                },
                isVisible: { [capabilities] _ in
                    capabilities.contains(.combinedVirtualRestrictions)
                }
            ),
            ToolbarActionDefinition(
                title: "Save",
                image: .save,
                handler: { [weak self] in
                    self?.didTapSave()
                },
                isVisible: { _ in true }
            ),
        ]
    }

    /// Recomputes toolbar visibility from the current overlay state.
    private func refreshToolbarItems() {
        updateToolbarItems(forSelectedSegmentIDs: [])
    }

    // MARK: - Map handling

    /// Disables segment selection because this editor only works with overlay-based restrictions.
    override func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        false
    }

    /// Applies incoming map data and restores the editable restriction overlays when appropriate.
    override func applyMapData(_ data: VTMapData) async {
        await super.applyMapData(data)

        mapView?.didChangeOverlaySelection = { [weak self] selectedOverlayID in
            self?.refreshToolbarItems()
            guard selectedOverlayID != nil else { return }
            self?.becomeFirstResponder()
        }
        mapView?.didMutateOverlays = { [weak self] in
            self?.hasLocalChanges = true
            self?.refreshToolbarItems()
        }

        if !hasLocalChanges {
            await mapView?.setTransientOverlays(loadRestrictionOverlays(fallbackMapData: data))
        }

        refreshToolbarItems()
    }

    // MARK: - Overlay Loading

    /// Converts embedded map entities into editable overlay objects.
    private func overlays(from data: VTMapData) -> [VTMapOverlay] {
        data.entities.compactMap { entity in
            switch entity.type {
            case .no_go_area:
                rectangleOverlay(for: entity, type: .no_go_area)
            case .no_mop_area:
                rectangleOverlay(for: entity, type: .no_mop_area)
            case .virtual_wall:
                wallOverlay(for: entity)
            default:
                nil
            }
        }
    }

    /// Builds a rectangular restriction overlay from a map entity if its geometry is valid.
    private func rectangleOverlay(for entity: VTEntity, type: VTEntityType) -> VTMapOverlay? {
        guard entity.points.count >= 8,
              let mapView
        else { return nil }

        let pixelSize = Double(mapView.data.pixelSize)
        // Restriction entities arrive as centimeter-space corner coordinates. They are normalized
        // into overlay points so the editable rectangles line up with the rendered map image.
        let corners = stride(from: 0, to: 8, by: 2).map { index in
            mapView.overlayPoint(
                fromMapCoordinate: CGPoint(
                    x: Double(entity.points[index]) / pixelSize,
                    y: Double(entity.points[index + 1]) / pixelSize
                )
            )
        }

        let minX = corners.map(\.x).min() ?? 0
        let minY = corners.map(\.y).min() ?? 0
        let maxX = corners.map(\.x).max() ?? 0
        let maxY = corners.map(\.y).max() ?? 0
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

        switch type {
        case .no_go_area:
            return VTNoGoAreaMapOverlay(rect: rect)
        case .no_mop_area:
            return VTNoMopAreaMapOverlay(rect: rect)
        default:
            return nil
        }
    }

    /// Builds a virtual wall overlay from a map entity if its endpoints are present.
    private func wallOverlay(for entity: VTEntity) -> VTMapOverlay? {
        guard entity.points.count >= 4,
              let mapView
        else { return nil }

        let pixelSize = Double(mapView.data.pixelSize)
        let start = mapView.overlayPoint(
            fromMapCoordinate: CGPoint(
                x: Double(entity.points[0]) / pixelSize,
                y: Double(entity.points[1]) / pixelSize
            )
        )
        let end = mapView.overlayPoint(
            fromMapCoordinate: CGPoint(
                x: Double(entity.points[2]) / pixelSize,
                y: Double(entity.points[3]) / pixelSize
            )
        )
        return VTVirtualWallMapOverlay(startPoint: start, endPoint: end)
    }

    /// Converts the backend restriction payload into editable overlays.
    private func overlays(from restrictions: VTVirtualRestrictions) -> [VTMapOverlay] {
        let wallOverlays = restrictions.virtualWalls.map { wall in
            VTVirtualWallMapOverlay(
                startPoint: overlayPoint(from: wall.points.pA),
                endPoint: overlayPoint(from: wall.points.pB)
            )
        }

        let zoneOverlays = restrictions.restrictedZones.compactMap { zone -> VTMapOverlay? in
            let points = [zone.points.pA, zone.points.pB, zone.points.pC, zone.points.pD].map(overlayPoint(from:))
            let minX = points.map(\.x).min() ?? 0
            let minY = points.map(\.y).min() ?? 0
            let maxX = points.map(\.x).max() ?? 0
            let maxY = points.map(\.y).max() ?? 0
            let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

            switch zone.type {
            case .regular:
                return VTNoGoAreaMapOverlay(rect: rect)
            case .mop:
                return VTNoMopAreaMapOverlay(rect: rect)
            }
        }

        return wallOverlays + zoneOverlays
    }

    /// Fetches restriction capability metadata such as the supported restricted zone types.
    private func loadVirtualRestrictionProperties() async {
        do {
            let properties = try await client.getVirtualRestrictionsProperties()
            supportedRestrictedZoneTypes = Set(properties.supportedRestrictedZoneTypes)
        } catch {
            log(
                message: "CombinedVirtualRestrictionsCapability properties failed: \(error.localizedDescription)",
                forSubsystem: .mapOptions,
                level: .error
            )
            supportedRestrictedZoneTypes = []
        }

        refreshToolbarItems()
    }

    /// Loads the latest restrictions from the backend, falling back to map-embedded entities if needed.
    private func loadRestrictionOverlays(fallbackMapData: VTMapData) async -> [VTMapOverlay] {
        do {
            let restrictions = try await client.getVirtualRestrictions()
            return overlays(from: restrictions)
        } catch {
            log(
                message: "CombinedVirtualRestrictionsCapability fetch failed: \(error.localizedDescription)",
                forSubsystem: .mapOptions,
                level: .error
            )
            return overlays(from: fallbackMapData)
        }
    }

    /// Converts a backend map coordinate into the overlay coordinate space used by the editor.
    private func overlayPoint(from coordinate: VTMapCoordinate) -> CGPoint {
        guard let mapView else { return .zero }

        let pixelSize = Double(mapView.data.pixelSize)
        return mapView.overlayPoint(
            fromMapCoordinate: CGPoint(
                x: Double(coordinate.x) / pixelSize,
                y: Double(coordinate.y) / pixelSize
            )
        )
    }

    // MARK: - Toolbar item Callbacks

    /// Inserts a new no-go overlay for the user to position on the map.
    private func didTapAddNoGo() {
        hasLocalChanges = true
        mapView?.addOverlay(VTNoGoAreaMapOverlay(rect: .zero))
        refreshToolbarItems()
    }

    /// Inserts a new no-mop overlay for the user to position on the map.
    private func didTapAddNoMop() {
        hasLocalChanges = true
        mapView?.addOverlay(VTNoMopAreaMapOverlay(rect: .zero))
        refreshToolbarItems()
    }

    /// Inserts a new virtual wall overlay with a short default length.
    private func didTapAddWall() {
        hasLocalChanges = true
        mapView?.addOverlay(
            VTVirtualWallMapOverlay(
                startPoint: .zero,
                endPoint: CGPoint(x: 40, y: 0)
            )
        )
        refreshToolbarItems()
    }

    /// Removes the currently selected restriction overlay from the editor.
    private func didTapRemove() {
        guard let selectedRestrictionOverlayID else { return }
        hasLocalChanges = true
        mapView?.removeOverlay(withID: selectedRestrictionOverlayID)
        refreshToolbarItems()
    }

    /// Persists the current editable overlays back to the backend restriction endpoint.
    private func didTapSave() {
        Task { [weak self] in
            guard let self else { return }
            guard let payload = currentVirtualRestrictions() else { return }

            do {
                try await client.setVirtualRestrictions(payload)
                // Keep local overlays authoritative until the refresh completes. The backend can
                // briefly return the pre-save restriction set, which would otherwise make removed
                // areas flicker back into view while the loading spinner is still visible.
                try? await loadMap()
                hasLocalChanges = false
            } catch {
                log(message: "CombinedVirtualRestrictionsCapability save failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
                showError(
                    title: "ERROR".localized(),
                    message: error.localizedDescription
                )
            }
        }
    }

    /// Serializes the current editable overlays into the backend virtual restriction payload.
    private func currentVirtualRestrictions() -> VTVirtualRestrictions? {
        guard let mapView else { return nil }

        let virtualWalls = restrictionOverlays.compactMap { overlay -> VTVirtualWallPayload? in
            guard let wall = overlay as? VTVirtualWallMapOverlay else { return nil }
            return VTVirtualWallPayload(
                points: VTVirtualWallPoints(
                    pA: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: wall.startPoint)),
                    pB: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: wall.endPoint))
                )
            )
        }

        let restrictedZones = restrictionOverlays.compactMap { overlay -> VTRestrictedZonePayload? in
            guard let zone = overlay as? VTRectangularVirtualRestrictionMapOverlay else { return nil }

            let topLeft = zone.rect.origin
            let topRight = CGPoint(x: zone.rect.maxX, y: zone.rect.minY)
            let bottomRight = CGPoint(x: zone.rect.maxX, y: zone.rect.maxY)
            let bottomLeft = CGPoint(x: zone.rect.minX, y: zone.rect.maxY)
            let type: VTVirtualRestrictedZoneType = zone is VTNoMopAreaMapOverlay ? .mop : .regular

            return VTRestrictedZonePayload(
                type: type,
                points: VTRectangularRestrictedZonePoints(
                    pA: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: topLeft)),
                    pB: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: topRight)),
                    pC: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: bottomRight)),
                    pD: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: bottomLeft))
                )
            )
        }

        return VTVirtualRestrictions(virtualWalls: virtualWalls, restrictedZones: restrictedZones)
    }

    /// Converts an overlay-space point back into the integer map coordinate format expected by the API.
    private func coordinate(from point: CGPoint) -> VTMapCoordinate {
        VTMapCoordinate(x: Int(point.x.rounded()), y: Int(point.y.rounded()))
    }
}
