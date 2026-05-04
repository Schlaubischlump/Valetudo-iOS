//
//  VTQuirksOptionsViewController.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import UIKit

final class VTQuirksOptionsViewController: VTRobotOptionsViewControllerBase<VTQuirksOptionsSection> {
    private let client: any VTAPIClientProtocol

    private var quirks: [VTQuirk] = []

    init(client: any VTAPIClientProtocol) {
        self.client = client

        super.init()
        title = "ROBOT_SYSTEM_QUIRKS".localized()
    }

    override func title(forSection: VTQuirksOptionsSection) -> String {
        forSection.title
    }

    override func sections() -> [VTQuirksOptionsSection] {
        [.main]
    }

    override func items(forSection: VTQuirksOptionsSection) -> [VTAnyItem] {
        switch forSection {
        case .main:
            quirks.map { quirk in
                .dropDown(
                    quirk.id,
                    title: quirk.title,
                    subtitle: quirk.description,
                    active: quirk.value,
                    options: quirk.options
                )
            }
        }
    }

    override func cellRegistration(forType: any VTItem.Type) -> VTCellRegistration {
        switch forType {
        case is VTDropDownItem<String>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
                guard let item = wrappedItem.base as? VTDropDownItem<String> else {
                    fatalError("Unsupported checkbox item: \(wrappedItem.base)")
                }

                cell.contentConfiguration = VTDropDownCellContentConfiguration(
                    id: item.id,
                    title: item.title,
                    subtitle: item.subtitle,
                    options: item.options,
                    selection: item.active,
                    disableSelectionAfterAction: true
                ) { [weak self] newActive in
                    guard let self else { return }
                    performUpdate(operationName: "Update Quirk \(item.title)", itemID: item.id) { [client] in
                        try await client.setQuirk(id: item.id, value: newActive)
                    }
                }
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = []
            }
        default:
            fatalError("Unsupported cell registration for type \(forType)")
        }
    }

    override var supportedCellTypes: [any VTItem.Type] {
        [
            VTDropDownItem<String>.self,
        ]
    }

    override func updateState() async {
        quirks = await (try? client.getQuirks()) ?? []
    }
}
