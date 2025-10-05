//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 05.10.25.
//
import UIKit

struct VTLogLineCellContentConfiguration: UIContentConfiguration {
    let timestamp: Date
    let level: String
    let message: String

    func makeContentView() -> UIView & UIContentView {
        return VTLogLineCellView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTLogLineCellContentConfiguration {
        self
    }
}
