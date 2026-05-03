//
//  VTCarpetSensorModeControlProperties.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTCarpetSensorModeControlProperties: Decodable, Sendable, Hashable {
    let supportedModes: [VTCarpetSensorMode]
}
