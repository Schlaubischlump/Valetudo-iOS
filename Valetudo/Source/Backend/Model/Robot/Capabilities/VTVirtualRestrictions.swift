//
//  VTVirtualRestrictions.swift
//  Valetudo
//
//  Created by David Klopp on 09.10.25.
//

import Foundation

public enum VTVirtualRestrictedZoneType: String, Codable, Hashable, Sendable {
    case regular
    case mop
}

public struct VTVirtualWallPoints: Codable, Hashable, Sendable {
    public let pA: VTMapCoordinate
    public let pB: VTMapCoordinate

    public init(pA: VTMapCoordinate, pB: VTMapCoordinate) {
        self.pA = pA
        self.pB = pB
    }
}

public struct VTVirtualWallPayload: Codable, Hashable, Sendable {
    public let points: VTVirtualWallPoints

    public init(points: VTVirtualWallPoints) {
        self.points = points
    }
}

public struct VTRectangularRestrictedZonePoints: Codable, Hashable, Sendable {
    public let pA: VTMapCoordinate
    public let pB: VTMapCoordinate
    public let pC: VTMapCoordinate
    public let pD: VTMapCoordinate

    public init(pA: VTMapCoordinate, pB: VTMapCoordinate, pC: VTMapCoordinate, pD: VTMapCoordinate) {
        self.pA = pA
        self.pB = pB
        self.pC = pC
        self.pD = pD
    }
}

public struct VTRestrictedZonePayload: Codable, Hashable, Sendable {
    public let type: VTVirtualRestrictedZoneType
    public let points: VTRectangularRestrictedZonePoints

    public init(type: VTVirtualRestrictedZoneType, points: VTRectangularRestrictedZonePoints) {
        self.type = type
        self.points = points
    }
}

public struct VTVirtualRestrictions: Codable, Hashable, Sendable {
    public let virtualWalls: [VTVirtualWallPayload]
    public let restrictedZones: [VTRestrictedZonePayload]

    public init(virtualWalls: [VTVirtualWallPayload], restrictedZones: [VTRestrictedZonePayload]) {
        self.virtualWalls = virtualWalls
        self.restrictedZones = restrictedZones
    }
}
