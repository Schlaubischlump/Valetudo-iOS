//
//  VTRobotCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 23.04.26.
//
import UIKit

struct VTRobotCellContentConfiguration: UIContentConfiguration, Hashable {
    let robot: VTMDNSRobot

    func makeContentView() -> UIView & UIContentView {
        VTRobotCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTRobotCellContentConfiguration {
        self
    }
}
