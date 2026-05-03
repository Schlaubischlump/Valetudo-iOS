//
//  VTZoneCleaningCapabilityProperties.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import Foundation

public struct VTZoneCleaningCapabilityProperties: Decodable, Sendable, Hashable {
    let zoneCount: VTZoneCleaningCountRange
    let iterationCount: VTZoneCleaningCountRange
}
