//
//  VTVirtualRestrictionManagementViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

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

    init(client: VTAPIClientProtocol, capabilities: Set<VTCapability>) {
        self.capabilities = capabilities
        super.init(client: client)
        title = "MAP_OPTIONS_VIRTUAL_RESTRICTION_MANAGEMENT_TITLE".localized()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard capabilities.contains(.combinedVirtualRestrictions) else { return }
        Task { [weak self] in
            await self?.loadVirtualRestrictionProperties()
        }
    }

    // MARK: - Toolbar setup

    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        [
            ToolbarActionDefinition(
                title: "Remove",
                image: .trash,
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

    private func refreshToolbarItems() {
        updateToolbarItems(forSelectedSegmentIDs: [])
    }

    // MARK: - Map handling

    override func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        false
    }

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

    private func rectangleOverlay(for entity: VTEntity, type: VTEntityType) -> VTMapOverlay? {
        guard entity.points.count >= 8,
              let mapView
        else { return nil }

        let pixelSize = Double(mapView.data.pixelSize)
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
            supportedRestrictedZoneTypes = [.regular, .mop]
        }

        refreshToolbarItems()
    }

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

    private func didTapAddNoGo() {
        hasLocalChanges = true
        mapView?.addOverlay(VTNoGoAreaMapOverlay(rect: .zero))
        refreshToolbarItems()
    }

    private func didTapAddNoMop() {
        hasLocalChanges = true
        mapView?.addOverlay(VTNoMopAreaMapOverlay(rect: .zero))
        refreshToolbarItems()
    }

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

    private func didTapRemove() {
        guard let selectedRestrictionOverlayID else { return }
        hasLocalChanges = true
        mapView?.removeOverlay(withID: selectedRestrictionOverlayID)
        refreshToolbarItems()
    }

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

    private func coordinate(from point: CGPoint) -> VTMapCoordinate {
        VTMapCoordinate(
            x: Int(point.x.rounded()),
            y: Int(point.y.rounded())
        )
    }
}
