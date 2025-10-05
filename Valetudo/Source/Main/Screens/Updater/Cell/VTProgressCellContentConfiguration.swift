//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

struct VTProgressCellContentConfiguration: UIContentConfiguration, Hashable {
    var message: String
    var progress: Double
    
    func makeContentView() -> UIView & UIContentView {
        VTUpdateProgressCellView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTProgressCellContentConfiguration {
        self
    }
}
