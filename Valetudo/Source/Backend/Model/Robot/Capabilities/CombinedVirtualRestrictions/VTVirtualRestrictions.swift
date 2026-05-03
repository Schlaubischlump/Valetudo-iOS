//
//  VTVirtualRestrictions.swift
//  Valetudo
//
//  Created by David Klopp on 09.10.25.
//

import Foundation

public struct VTVirtualRestrictions: Codable, Hashable, Sendable {
    public let virtualWalls: [VTVirtualWallPayload]
    public let restrictedZones: [VTRestrictionsZonePayload]

    public init(virtualWalls: [VTVirtualWallPayload], restrictedZones: [VTRestrictionsZonePayload]) {
        self.virtualWalls = virtualWalls
        self.restrictedZones = restrictedZones
    }
}
