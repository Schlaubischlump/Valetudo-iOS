//
//  VTMopDockMopWashTemperatureControlProperties.swift
//  Valetudo
//

import Foundation

public struct VTMopDockMopWashTemperatureControlProperties: Decodable, Sendable, Hashable {
    let supportedTemperatures: [VTMopDockMopWashTemperature]
}
