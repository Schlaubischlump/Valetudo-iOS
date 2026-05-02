//
//  VTTextFieldContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTTextFieldCellContentConfiguration: VTStackedCellContentConfiguration {
    let id: String
    let title: String
    let subtitle: String?
    let image: UIImage?
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
            lhs.title == rhs.title &&
            lhs.placeholder == rhs.placeholder &&
            lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(placeholder)
        hasher.combine(text)
    }
}
