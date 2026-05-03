//
//  VTWifiConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTWifiConfiguration: Codable, Sendable, Hashable {
    enum State: String, Codable, Hashable {
        case connected
        case notConnected = "not_connected"
        case unknown
    }

    let state: State
    let details: VTWifiDetails?
    let metaData: [String: VTAnyCodable]
}
