//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

struct VTProgressCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let message: String
    var progress: Double

    func makeContentView() -> UIView & UIContentView {
        VTProgressCellView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> VTProgressCellContentConfiguration {
        self
    }
}
