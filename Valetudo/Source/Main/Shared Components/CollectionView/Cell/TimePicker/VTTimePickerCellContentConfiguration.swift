//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTTimePickerCellContentConfiguration: VTStackedCellContentConfiguration {
    let id: String
    let title: String
    let subtitle: String?
    let image: UIImage?
    let hours: Int
    let minutes: Int

    var disableSelectionAfterAction: Bool = true
    let onChange: ((Int, Int) -> Void)?
    var isEnabled: Bool = true

    func makeContentView() -> UIView & UIContentView {
        VTTimePickerCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.image == rhs.image &&
            lhs.hours == rhs.hours &&
            lhs.minutes == rhs.minutes &&
            lhs.isEnabled == rhs.isEnabled &&
            lhs.disableSelectionAfterAction == rhs.disableSelectionAfterAction
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(image)
        hasher.combine(isEnabled)
        hasher.combine(disableSelectionAfterAction)
        hasher.combine(hours)
        hasher.combine(minutes)
    }
}
