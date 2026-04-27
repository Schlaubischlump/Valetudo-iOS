//
//  VTSystemInformationItem.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

enum VTSystemInformationItem: Hashable {
    case keyValuePair(title: String, subtitle: String? = nil)
    case segmentedBar(config: VTStackedProgressBarCellContentConfiguration)
    case link(title: String, children: [VTSystemInformationSection: [VTSystemInformationItem]])
}
