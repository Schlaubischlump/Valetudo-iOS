//
//  VTActionCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//
import UIKit

struct VTActionCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    var title: String
    var subtitle: String
    var image: UIImage?
    var buttonTitle: String
    var buttonStyle: VTButtonStyle? = nil
    var onAction: (() -> Void)? = nil

    func makeContentView() -> UIView & UIContentView {
        VTActionCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTActionCellContentConfiguration {
        self
    }

    static func == (lhs: VTActionCellContentConfiguration, rhs: VTActionCellContentConfiguration) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.image == rhs.image &&
        lhs.buttonTitle == rhs.buttonTitle &&
        lhs.buttonStyle == rhs.buttonStyle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(image)
        hasher.combine(buttonTitle)
        hasher.combine(buttonStyle)
    }
}
