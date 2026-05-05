//
//  VTStackedCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//

import UIKit

protocol VTStackedCellContentConfiguration: UIContentConfiguration, Hashable {
    var id: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var image: UIImage? { get }
}
