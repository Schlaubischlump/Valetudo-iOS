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
    let subtitleStyle: VTStackedCellSubtitleStyle
    let isOn: Bool
    let image: UIImage?
    var disableSelectionAfterAction: Bool = true
    let onChange: ((Bool) -> Void)?

    var isEnabled: Bool = true

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        subtitleStyle: VTStackedCellSubtitleStyle = .standard,
        isOn: Bool,
        image: UIImage? = nil,
        disableSelectionAfterAction: Bool = true,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.subtitleStyle = subtitleStyle
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
            lhs.subtitleStyle == rhs.subtitleStyle &&
            lhs.isOn == rhs.isOn &&
            lhs.image == rhs.image &&
            lhs.disableSelectionAfterAction == rhs.disableSelectionAfterAction &&
            lhs.isEnabled == rhs.isEnabled
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(subtitleStyle)
        hasher.combine(isOn)
        hasher.combine(image)
        hasher.combine(disableSelectionAfterAction)
        hasher.combine(isEnabled)
    }
}
