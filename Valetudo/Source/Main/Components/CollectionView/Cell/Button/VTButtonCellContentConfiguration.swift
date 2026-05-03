//
//  VTButtonCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import UIKit

struct VTButtonCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let title: String
    var disableSelectionAfterAction: Bool = true
    let action: (() -> Void)?

    var isEnabled: Bool = true

    init(
        id: String,
        title: String,
        disableSelectionAfterAction: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.disableSelectionAfterAction = disableSelectionAfterAction
        self.action = action
    }

    func makeContentView() -> UIView & UIContentView {
        VTButtonCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: VTButtonCellContentConfiguration, rhs: VTButtonCellContentConfiguration) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.disableSelectionAfterAction == rhs.disableSelectionAfterAction &&
            lhs.disableSelectionAfterAction == rhs.disableSelectionAfterAction &&
            lhs.isEnabled == rhs.isEnabled
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(disableSelectionAfterAction)
        hasher.combine(isEnabled)
    }
}
