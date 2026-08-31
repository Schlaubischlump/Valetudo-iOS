//
//  VTStackedCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//

import UIKit

enum VTStackedCellSubtitleStyle: Hashable {
    case standard
    case warning
}

protocol VTStackedCellContentConfiguration: UIContentConfiguration, Hashable {
    var id: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var subtitleStyle: VTStackedCellSubtitleStyle { get }
    var image: UIImage? { get }
}

extension VTStackedCellContentConfiguration {
    var subtitleStyle: VTStackedCellSubtitleStyle {
        .standard
    }
}
