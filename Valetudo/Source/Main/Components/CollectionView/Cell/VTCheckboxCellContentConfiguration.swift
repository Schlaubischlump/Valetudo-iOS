//
//  VTCheckboxContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTCheckboxCellContentConfiguration: VTStackedCellContentConfiguration {
    let id: String
    let title: String
    let subtitle: String?
    let isOn: Bool
    let image: UIImage?
    var disableSelectionAfterAction: Bool = true
    let onChange: ((Bool) -> Void)?

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        isOn: Bool,
        image: UIImage? = nil,
        disableSelectionAfterAction: Bool = true,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isOn = isOn
        self.image = image
        self.disableSelectionAfterAction = disableSelectionAfterAction
        self.onChange = onChange
    }

    func makeContentView() -> UIView & UIContentView {
        VTCheckboxCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: VTCheckboxCellContentConfiguration, rhs: VTCheckboxCellContentConfiguration) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.isOn == rhs.isOn &&
            lhs.image == rhs.image
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(isOn)
        hasher.combine(image)
    }
}
