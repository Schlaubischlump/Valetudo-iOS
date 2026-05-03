//
//  VTVirtualRestrictionsProperties.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//

public struct VTVirtualRestrictionsProperties: Decodable, Hashable, Sendable {
    let supportedRestrictedZoneTypes: [VTVirtualRestrictionsZoneType]
}
