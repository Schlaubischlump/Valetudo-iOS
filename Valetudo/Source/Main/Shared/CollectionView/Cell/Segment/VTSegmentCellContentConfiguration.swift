//
//  VTSegmentedCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTSegmentCellContentConfiguration<S: Describable & Hashable & Equatable>: UIContentConfiguration, Hashable {
    let id: String
    let options: [S]
    var active: Set<S>
    let onChange: ((Set<S>) -> Void)?

    func makeContentView() -> UIView & UIContentView {
        VTSegmentCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.options == rhs.options &&
            lhs.active == rhs.active
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(options)
        hasher.combine(active)
    }
}
