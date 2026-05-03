//
//  VTWifiCredentialConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

struct VTWifiCredentialConfiguration: Codable, Hashable {
    let type: String
    let typeSpecificSettings: [String: VTAnyCodable]
}
