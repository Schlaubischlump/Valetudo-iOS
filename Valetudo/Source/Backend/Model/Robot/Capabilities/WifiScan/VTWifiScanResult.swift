//
//  VTWifiScanResult.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTWifiScanResult: Decodable, Sendable, Hashable {
    let bssid: String
    let details: VTWifiScanDetails
    let metaData: [String: VTAnyCodable]
}
