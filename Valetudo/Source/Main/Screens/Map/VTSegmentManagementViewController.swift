//
//  VTSegmentManagementViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

@MainActor
final class VTSegmentManagementViewController: VTMapEditingViewController {
    private let capabilities: Set<VTCapability>

    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        [
            ToolbarActionDefinition(
                title: "MATERIAL".localized(),
                image: .rectangle3GroupFill,
                handler: { _ in },
                isVisible: { [capabilities] controller in
                    capabilities.contains(.mapSegmentMaterialControl) && controller.selectedSegmentCount == 1
                }
            ),
            ToolbarActionDefinition(
                title: "CUTTING_LINE".localized(),
                image: .scissors,
                handler: { _ in },
                isVisible: { [capabilities] controller in
                    capabilities.contains(.mapSegmentEdit) && controller.selectedSegmentCount == 1
                }
            ),
            ToolbarActionDefinition(
                title: "RENAME".localized(),
                image: .pencil,
                handler: { _ in },
                isVisible: { [capabilities] controller in
                    capabilities.contains(.mapSegmentRename) && controller.selectedSegmentCount == 1
                }
            ),
            ToolbarActionDefinition(
                title: "JOIN".localized(),
                image: .union,
                handler: { _ in },
                isVisible: { [capabilities] controller in
                    capabilities.contains(.mapSegmentEdit) && controller.selectedSegmentCount >= 2
                }
            ),
        ]
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
}
