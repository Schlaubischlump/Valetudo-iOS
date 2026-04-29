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
                    handler: {},
                    isVisible: { [capabilities] selectedSegments in
                        capabilities.contains(.mapSegmentRename) && selectedSegments.count == 1
                    }
                ),
                ToolbarActionDefinition(
                    title: "JOIN".localized(),
                    image: .union,
                    handler: {},
                    isVisible: { [capabilities] selectedSegments in
                        capabilities.contains(.mapSegmentEdit) && selectedSegments.count > 1
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
        refreshToolbarItems()
    }

    // MARK: - Toolbar item Callbacks
    
    private func showMaterialSelectionPopup() async throws -> VTMaterial? {
        guard let selectedMaterial = selectedSegments.first?.material else { return nil }

        let supportedMaterials = try await client.getSupportedMapSegmentMaterials()
        guard !supportedMaterials.isEmpty else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            let selectionViewController = VTMaterialSelectionViewController(
                materials: supportedMaterials,
                selectedMaterial: selectedMaterial
            ) { material in
                continuation.resume(returning: material)
            }

            let navigationController = UINavigationController(rootViewController: selectionViewController)
            navigationController.modalPresentationStyle = .formSheet

            present(navigationController, animated: true)
        }
    }
    
    private func didTapMaterial() {
        Task { [weak self] in
            guard let self else { return }
            do {
                if let material = try await showMaterialSelectionPopup(),
                   let segmentID = selectedSegments.first?.segmentId
                {
                    _ = try await performAndWaitForMapUpdate {
                        try await self.client.setMapSegmentMaterial(segmentID: segmentID, material: material)
                    }
                } else {
                    log(message: "MapSegmentMaterialControlCapability properties failed: Could not get material", forSubsystem: .mapOptions, level: .error)
                }
            } catch {
                log(message: "MapSegmentMaterialControlCapability properties failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }
    
    private func didTapCuttingLine() {
        mode = .split
        refreshToolbarItems()
    }

    private func didTapSplit(segment _: VTLayer) {
        // TODO: Split segment
    }

    private func didTapCancelSplitMode() {
        mode = .standard
        refreshToolbarItems()
    }

    private func refreshToolbarItems() {
        let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
        updateToolbarItems(forSelectedSegmentIDs: selectedSegmentIDs)
    }
}
