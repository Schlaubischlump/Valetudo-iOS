//
//  VTWifiConfigurationCapabilityProperties.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation

public struct VTWifiConfigurationCapabilityProperties: Decodable, Sendable, Hashable {
    let provisionedReconfigurationSupported: Bool
}
