//
//  VTWifiConfigurationAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTWifiConfigurationAction: Codable, Sendable, Hashable {
    let ssid: String
    let credentials: VTWifiCredentialConfiguration
    let metaData: [String: VTAnyCodable]?
}
