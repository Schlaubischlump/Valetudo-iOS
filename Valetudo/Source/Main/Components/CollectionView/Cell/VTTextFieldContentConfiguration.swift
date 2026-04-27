//
//  VTTextFieldContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTTextFieldCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let label: String
    let placeholder: String
    let text: String
    let onChange: ((String) -> Void)?

    func makeContentView() -> UIView & UIContentView {
        VTTextFieldCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: VTTextFieldCellContentConfiguration, rhs: VTTextFieldCellContentConfiguration) -> Bool {
        lhs.id == rhs.id &&
            lhs.label == rhs.label &&
            lhs.placeholder == rhs.placeholder &&
            lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(placeholder)
        hasher.combine(text)
    }
}
