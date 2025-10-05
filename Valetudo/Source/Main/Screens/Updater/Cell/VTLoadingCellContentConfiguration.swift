//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

struct VTLoadingCellConfiguration: UIContentConfiguration, Hashable {
    func makeContentView() -> UIView & UIContentView {
        return VTLoadingCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTLoadingCellConfiguration {
        return self
    }
}
