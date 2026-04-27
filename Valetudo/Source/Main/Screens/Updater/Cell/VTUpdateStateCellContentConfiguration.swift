//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

struct VTUpdateStateCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    var message: String
    var image: UIImage?
    var tintColor: UIColor

    func makeContentView() -> UIView & UIContentView {
        VTUpdateStateCellView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> VTUpdateStateCellContentConfiguration {
        self
    }
}
