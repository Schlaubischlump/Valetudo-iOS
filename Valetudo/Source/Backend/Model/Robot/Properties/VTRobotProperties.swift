//
//  VTRobotProperties.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

public typealias VTRobotProperties = [String: String]

extension VTRobotProperties {
    var firmwareVersion: String? {
        self["firmwareVersion"]
    }
}
