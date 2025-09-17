//
//  VTStackedProgressBarCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

struct VTStackedProgressBarCellContentConfiguration: UIContentConfiguration, Hashable {
    var title: String?
    var bars: [[VTStackedProgressBarSegment]]
    var legend: [VTStackedProgressBarLegendEntry]?
    var availableWidth: CGFloat = 0
    
    func makeContentView() -> UIView & UIContentView {
        VTStackedProgressBarView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTStackedProgressBarCellContentConfiguration {
        self
    }
}
