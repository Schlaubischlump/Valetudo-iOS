//
//  VTSegmentManagementViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

@MainActor
final class VTSegmentManagementViewController: VTMapEditingViewController {
    private enum Mode {
        case standard
        case split
    }

    private let capabilities: Set<VTCapability>
    private var mode: Mode = .standard
    private var splitOverlayID: UUID?

    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        switch mode {
        case .split:
            [
                ToolbarActionDefinition(
                    title: "Split",
                    image: .split,
                    handler: { [weak self] in
                        guard let segment = self?.selectedSegments.first else { return }
                        self?.didTapSplit(segment: segment)
                    },
                    isVisible: { _ in true }
                ),
                ToolbarActionDefinition(
                    title: "Cancel",
                    image: .xmark,
                    handler: { [weak self] in
                        self?.didTapCancelSplitMode()
                    },
                    isVisible: { _ in true }
                ),
            ]
        case .standard:
            [
                ToolbarActionDefinition(
                    title: "MATERIAL".localized(),
                    image: .rectangle3GroupFill,
                    handler: { [weak self] in
                        self?.didTapMaterial()
                    },
                    isVisible: { [capabilities] selectedSegments in
                        capabilities.contains(.mapSegmentMaterialControl) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "CUTTING_LINE".localized(),
                    image: .scissors,
                    handler: { [weak self] in
                        self?.didTapCuttingLine()
                    },
                    isVisible: { [capabilities] selectedSegments in
                        capabilities.contains(.mapSegmentEdit) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "RENAME".localized(),
                    image: .pencil,
                    handler: { [weak self] in
                        self?.didTapRename()
                    },
                    isVisible: { [capabilities] selectedSegments in
                        capabilities.contains(.mapSegmentRename) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "JOIN".localized(),
                    image: .union,
                    handler: { [weak self] in
                        self?.didTapJoin()
                    },
                    isVisible: { [capabilities] selectedSegments in
                        capabilities.contains(.mapSegmentEdit) && selectedSegments.count == 2
                    }
                ),
            ]
        }
    }

    init(client: VTAPIClientProtocol, capabilities: Set<VTCapability>) {
        self.capabilities = capabilities
        super.init(client: client)
        title = "MAP_OPTIONS_SEGMENT_MANAGEMENT_TITLE".localized()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Map handling

    override func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        mode == .standard
    }

    override func filterMapData(from mapData: VTMapData) -> VTMapData {
        let filteredEntities = mapData.entities.filter {
            switch $0.type {
            case .charger_location, .virtual_wall, .obstacle, .carpet: true
            default: false
            }
        }

        return VTMapData(
            size: mapData.size,
            pixelSize: mapData.pixelSize,
            layers: mapData.layers,
            entities: filteredEntities,
            metaData: mapData.metaData
        )
    }

    override func applyMapData(_ data: VTMapData) async {
        await super.applyMapData(data)

        guard mode == .split, selectedSegments.isEmpty else { return }
        mode = .standard
        splitOverlayID = nil
        refreshToolbarItems()
    }

    // MARK: - Toolbar item Callbacks

    private func didTapMaterial() {
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let material = try await showMaterialSelectionAlert() else { return }
                guard let segmentID = selectedSegments.first?.segmentId else {
                    log(message: "MapSegmentMaterialControlCapability properties failed: Missing segment selection", forSubsystem: .mapOptions, level: .error)
                    showError(
                        title: "ERROR".localized(),
                        message: "MAP_OPTIONS_SEGMENT_MATERIAL_FAILED_MESSAGE".localized()
                    )
                    return
                }

                try await performAndWaitForMapUpdate { [weak self] in
                    try await self?.client.setMapSegmentMaterial(segmentID: segmentID, material: material)
                }
            } catch {
                log(message: "MapSegmentMaterialControlCapability properties failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
                showError(
                    title: "ERROR".localized(),
                    message: String(
                        format: "MAP_OPTIONS_SEGMENT_MATERIAL_FAILED_MESSAGE_WITH_REASON".localized(),
                        error.localizedDescription
                    )
                )
            }
        }
    }

    private func didTapCuttingLine() {
        guard let segment = selectedSegments.first,
              let mapView
        else { return }

        mode = .split
        let segmentWidth = CGFloat(segment.dimensions.x.max - segment.dimensions.x.min)
        let segmentHeight = CGFloat(segment.dimensions.y.max - segment.dimensions.y.min)
        let lineLength = max(32.0, min(max(segmentWidth, segmentHeight) * 0.5, 96.0))
        let lineThickness = 3.0
        let segmentCenter = CGPoint(
            x: CGFloat(segment.dimensions.x.mid),
            y: CGFloat(segment.dimensions.y.mid)
        )
        let overlay = VTSplitLineMapOverlay(
            center: mapView.overlayPoint(fromMapCoordinate: segmentCenter),
            length: lineLength,
            thickness: lineThickness,
            dashPattern: [2, 2],
            strokeWidth: 1.0
        )
        splitOverlayID = mapView.addOverlay(overlay)
        refreshToolbarItems()
    }

    private func didTapSplit(segment _: VTLayer) {
        Task { [weak self] in
            guard let self,
                  let segmentID = selectedSegments.first?.segmentId,
                  let splitLine = currentSplitLine
            else {
                log(message: "MapSegmentEditCapability split failed: Missing split line or segment selection", forSubsystem: .mapOptions, level: .error)
                return
            }

            do {
                try await performAndWaitForMapUpdate { [weak self] in
                    try await self?.client.splitMapSegment(
                        segmentID: segmentID,
                        pointA: splitLine.start,
                        pointB: splitLine.end
                    )
                }
                didTapCancelSplitMode()
            } catch {
                log(message: "MapSegmentEditCapability split failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
                showError(
                    title: "ERROR".localized(),
                    message: String(
                        format: "MAP_OPTIONS_SEGMENT_SPLIT_FAILED_MESSAGE".localized(),
                        error.localizedDescription
                    )
                )
            }
        }
    }

    private func didTapCancelSplitMode() {
        mode = .standard
        splitOverlayID = nil
        mapView?.clearTransientOverlays()
        refreshToolbarItems()
    }

    /// Returns the current split line geometry in Valetudo's cm-space.
    private var currentSplitLine: (start: CGPoint, end: CGPoint)? {
        guard let splitOverlayID,
              let splitLine = mapView?.overlay(withID: splitOverlayID) as? VTSplitLineMapOverlay,
              let mapView
        else { return nil }

        return (
            start: mapView.cmCoordinate(fromOverlayPoint: splitLine.startPoint),
            end: mapView.cmCoordinate(fromOverlayPoint: splitLine.endPoint)
        )
    }

    private func refreshToolbarItems() {
        let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
        updateToolbarItems(forSelectedSegmentIDs: selectedSegmentIDs)
    }

    private func didTapRename() {
        Task { [weak self] in
            guard let self,
                  let segment = selectedSegments.first,
                  let segmentID = segment.segmentId
            else { return }

            do {
                guard let newName = try await showRenameAlert(for: segment)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                    !newName.isEmpty,
                    newName != segment.name
                else { return }

                try await performAndWaitForMapUpdate { [weak self] in
                    try await self?.client.renameMapSegment(segmentID: segmentID, name: newName)
                }
            } catch {
                log(message: "MapSegmentRenameCapability rename failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }

    private func didTapJoin() {
        Task { [weak self] in
            guard let self else { return }

            let segments = selectedSegments
            guard segments.count == 2,
                  let firstSegmentID = segments[0].segmentId,
                  let secondSegmentID = segments[1].segmentId
            else { return }

            do {
                try await performAndWaitForMapUpdate { [weak self] in
                    try await self?.client.joinMapSegments(segmentAID: firstSegmentID, segmentBID: secondSegmentID)
                }
            } catch {
                log(message: "MapSegmentEditCapability join failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }

    // MARK: - Alerts

    private func showRenameAlert(for segment: VTLayer) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            let alert = UIAlertController(
                title: "RENAME".localized(),
                message: segment.description,
                preferredStyle: .alert
            )

            alert.addTextField { textField in
                textField.text = segment.name
                textField.clearButtonMode = .whileEditing
                textField.returnKeyType = .done
            }

            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel) { _ in
                continuation.resume(returning: nil)
            })
            alert.addAction(UIAlertAction(title: "RENAME".localized(), style: .default) { _ in
                continuation.resume(returning: alert.textFields?.first?.text)
            })

            presentAlertControllerSafely(alert)
        }
    }

    private func showMaterialSelectionAlert() async throws -> VTMaterial? {
        guard let selectedMaterial = selectedSegments.first?.material else { return nil }

        let supportedMaterials = try await client.getSupportedMapSegmentMaterials()
        guard !supportedMaterials.isEmpty else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            let alert = UIAlertController(
                title: "MATERIAL".localized(),
                message: nil,
                preferredStyle: .actionSheet
            )

            for material in supportedMaterials {
                let title = material == selectedMaterial ? "✓ \(material.description)" : material.description
                alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                    continuation.resume(returning: material)
                })
            }

            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel) { _ in
                continuation.resume(returning: nil)
            })

            if let popover = alert.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 1,
                    height: 1
                )
                popover.permittedArrowDirections = []
            }

            presentAlertControllerSafely(alert)
        }
    }
}
