//
//  VTNetworkAdvertisementProperties.swift
//  Valetudo
//
//  Created by David Klopp on 25.04.26.
//

public struct VTNetworkAdvertisementProperties: Decodable, Sendable, Hashable, Equatable {
    let port: Int
    let zeroconfHostname: String
}
