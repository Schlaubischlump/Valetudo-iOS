//
//  VTMopDockMopDryingTimeControlProperties.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTMopDockMopDryingTimeControlProperties: Decodable, Sendable, Hashable {
    let supportedDurations: [VTMopDockMopDryingDuration]
}
