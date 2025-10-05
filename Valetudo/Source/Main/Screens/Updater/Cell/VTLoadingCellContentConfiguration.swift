//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

struct VTLoadingCellContentConfiguration: UIContentConfiguration, Hashable {
    var message: String
    
    func makeContentView() -> UIView & UIContentView {
        VTLoadingCellView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTLoadingCellContentConfiguration {
        self
    }
}
