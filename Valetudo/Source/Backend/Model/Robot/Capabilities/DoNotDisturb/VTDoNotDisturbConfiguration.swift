//
//  VTDoNotDisturbConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTDoNotDisturbConfiguration: Codable, Sendable, Hashable {
    let enabled: Bool
    let start: VTDoNotDisturbTime
    let end: VTDoNotDisturbTime
    let metaData: [String: VTAnyCodable]
}
