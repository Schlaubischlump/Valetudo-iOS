//
//  VTKeyValueCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//

import UIKit

struct VTKeyValueCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let title: String
    let value: String?
    let usesHorizontalLayout: Bool
    var image: UIImage?

    func makeContentView() -> any UIView & UIContentView {
        VTKeyValueCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }
}
