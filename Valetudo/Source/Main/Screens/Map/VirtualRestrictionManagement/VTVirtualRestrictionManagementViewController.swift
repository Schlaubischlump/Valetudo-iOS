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

    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        [
            ToolbarActionDefinition(
                title: "No-Mop",
                image: .noMop,
                handler: { [weak self] in
                    self?.didTapRestriction(named: "No-Mop")
                },
                isVisible: { [capabilities] _ in
                    capabilities.contains(.combinedVirtualRestrictions)
                }
            ),
            ToolbarActionDefinition(
                title: "No-Go",
                image: .noGo,
                handler: { [weak self] in
                    self?.didTapRestriction(named: "No-Go")
                },
                isVisible: { [capabilities] _ in
                    capabilities.contains(.combinedVirtualRestrictions)
                }
            ),
            ToolbarActionDefinition(
                title: "Wall",
                image: .wall,
                handler: { [weak self] in
                    self?.didTapRestriction(named: "Wall")
                },
                isVisible: { [capabilities] _ in
                    capabilities.contains(.combinedVirtualRestrictions)
                }
            ),
        ]
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

    private func didTapRestriction(named name: String) {
        showError(
            title: "ERROR".localized(),
            message: "\(name) restriction editing is not implemented yet."
        )
    }
}
