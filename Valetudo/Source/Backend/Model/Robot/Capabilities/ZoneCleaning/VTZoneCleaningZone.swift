//
//  VTZoneCleaningZone.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTZoneCleaningZone: Codable, Sendable, Hashable {
    let points: VTRectangularZonePoints
    let metaData: [String: VTAnyCodable]?
}
