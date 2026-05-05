//
//  VTSegmentManagementViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

/// Manages map segment editing actions such as rename, join, split, and material assignment.
@MainActor
final class VTSegmentManagementViewController: VTMapViewController {
    /// Describes the currently active editing mode for the segment toolbar.
    private enum Mode {
        case standard
        case split
    }

    private let capabilities: Set<VTCapability>
    private var mode: Mode = .standard

    private var splitOverlayID: UUID?

    // MARK: - Overlay Accessors

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

    /// Creates the segment management editor for a robot and its advertised capabilities.
    init(client: VTAPIClientProtocol, capabilities: Set<VTCapability>) {
        self.capabilities = capabilities
        super.init(client: client)
        title = "MAP_OPTIONS_SEGMENT_MANAGEMENT_TITLE".localized()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Toolbar Setup

    /// Returns the toolbar actions appropriate for the current segment editing mode.
    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        switch mode {
        case .split:
            [
                ToolbarActionDefinition(
                    title: "Split",
                    image: .splitSegments,
                    handler: { [weak self] in
                        guard let segment = self?.selectedSegments.first else { return }
                        self?.didTapSplit(segment: segment)
                    }
                ),
                ToolbarActionDefinition(
                    title: "Cancel",
                    image: .xmark,
                    handler: { [weak self] in
                        self?.didTapCancelSplitMode()
                    }
                ),
            ]
        case .standard:
            [
                ToolbarActionDefinition(
                    title: "MATERIAL".localized(),
                    image: .material,
                    handler: { [weak self] in
                        self?.didTapMaterial()
                    },
                    isVisible: { [weak self, capabilities] in
                        guard let self else { return false }
                        return capabilities.contains(.mapSegmentMaterialControl) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "CUTTING_LINE".localized(),
                    image: .insertCuttingLine,
                    handler: { [weak self] in
                        self?.didTapCuttingLine()
                    },
                    isVisible: { [weak self, capabilities] in
                        guard let self else { return false }
                        return capabilities.contains(.mapSegmentEdit) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "RENAME".localized(),
                    image: .rename,
                    handler: { [weak self] in
                        self?.didTapRename()
                    },
                    isVisible: { [weak self, capabilities] in
                        guard let self else { return false }
                        return capabilities.contains(.mapSegmentRename) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "JOIN".localized(),
                    image: .joinSegments,
                    handler: { [weak self] in
                        self?.didTapJoin()
                    },
                    isVisible: { [weak self, capabilities] in
                        guard let self else { return false }
                        return capabilities.contains(.mapSegmentEdit) && selectedSegments.count == 2
                    }
                ),
            ]
        }
    }

    // MARK: - Map Handling

    /// Removes entities unrelated to segment editing before the map is rendered.
    override func filterMapData(from mapData: VTMapData) -> VTMapData {
        let filteredEntities = mapData.entities.filter {
            switch $0.type {
            case .charger_location, .obstacle, .carpet: true
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

    /// Disables segment selection changes while the user is positioning a split line.
    override func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        mode == .standard
    }

    /// Leaves split mode automatically if the live map refresh removes the current selection.
    override func applyMapData(_ data: VTMapData) async {
        await super.applyMapData(data)

        guard mode == .split, selectedSegments.isEmpty else { return }
        mode = .standard
        splitOverlayID = nil
        updateToolbarItems()
    }

    // MARK: - Toolbar Item Callbacks

    /// Presents the material picker and applies the chosen material to the selected segment.
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

    /// Enters split mode and places an adjustable split overlay near the selected segment center.
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
        // Clamp the initial line length so small rooms still get a usable handle while large rooms
        // do not start with an oversized line that is hard to position precisely.
        let overlay = VTSplitLineMapOverlay(
            center: mapView.overlayPoint(fromMapCoordinate: segmentCenter),
            length: lineLength,
            thickness: lineThickness,
            strokeWidth: 1.0
        )
        splitOverlayID = mapView.addOverlay(overlay)
        updateToolbarItems()
    }

    /// Sends the current split line to the backend and waits for the resulting map update.
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

    /// Exits split mode and removes the transient split overlay from the map.
    private func didTapCancelSplitMode() {
        mode = .standard
        splitOverlayID = nil
        mapView?.clearTransientOverlays()
        updateToolbarItems()
    }

    /// Prompts for a new segment name and submits the rename if it changed.
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

    /// Joins the two selected segments into one backend-defined segment.
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

    /// Presents a rename alert for the provided segment and returns the entered name.
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

    /// Presents the material picker for the selected segment and returns the chosen material.
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
                // The action sheet uses a leading checkmark instead of a custom accessory view so it
                // remains compatible with the stock UIKit action sheet presentation.
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
