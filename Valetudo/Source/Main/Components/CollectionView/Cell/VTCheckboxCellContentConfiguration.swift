//
//  VTCheckboxContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTCheckboxCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let title: String
    let isOn: Bool
    var disableSelectionAfterAction: Bool = true
    let onChange: ((Bool) -> Void)?

    func makeContentView() -> UIView & UIContentView {
        VTCheckboxCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: VTCheckboxCellContentConfiguration, rhs: VTCheckboxCellContentConfiguration) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.isOn == rhs.isOn
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(isOn)
    }
}
