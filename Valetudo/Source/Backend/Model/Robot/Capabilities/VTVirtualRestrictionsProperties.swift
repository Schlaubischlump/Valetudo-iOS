//
//  VTVirtualRestrictionsProperties.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//
public enum VTVirtualRestrictionsZoneTypes: String, Codable, Hashable, Sendable {
    case regular
    case mop
}

public struct VTVirtualRestrictionsProperties: Decodable, Hashable, Sendable {
    let supportedRestrictedZoneTypes: [VTVirtualRestrictionsZoneTypes]
}
