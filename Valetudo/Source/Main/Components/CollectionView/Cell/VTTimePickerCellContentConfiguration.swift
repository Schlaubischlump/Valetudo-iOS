//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

struct VTTimePickerCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let label: String
    let hours: Int
    let minutes: Int
    let onChange: ((Int, Int) -> Void)?

    func makeContentView() -> UIView & UIContentView {
        VTTimePickerCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self { self }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
        lhs.hours == rhs.hours &&
        lhs.minutes == rhs.minutes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(hours)
        hasher.combine(minutes)
    }
}
