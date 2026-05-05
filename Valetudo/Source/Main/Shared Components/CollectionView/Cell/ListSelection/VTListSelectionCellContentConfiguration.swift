//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 15.04.26.
//
import UIKit

struct VTListSelectionCellContentConfiguration<T: Hashable & Sendable & Describable>: UIContentConfiguration, Hashable {
    let id: String
    var enabledTitle: String = "ENABLED"
    var disabledTitle: String = "DISABLED"
    var allowReordering: Bool = true
    let options: [T]
    let active: [T]
    let onChange: (([T]) -> Void)?

    func makeContentView() -> UIView & UIContentView {
        VTListSelectionCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.options == rhs.options &&
            lhs.active == rhs.active &&
            lhs.allowReordering == rhs.allowReordering &&
            lhs.enabledTitle == rhs.enabledTitle &&
            lhs.disabledTitle == rhs.disabledTitle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(enabledTitle)
        hasher.combine(disabledTitle)
        hasher.combine(allowReordering)
        hasher.combine(options)
        hasher.combine(active)
    }
}
