//
//  VTRestrictionsZonePayload.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTRestrictionsZonePayload: Codable, Hashable, Sendable {
    public let type: VTVirtualRestrictionsZoneType
    public let points: VTRectangularZonePoints

    public init(type: VTVirtualRestrictionsZoneType, points: VTRectangularZonePoints) {
        self.type = type
        self.points = points
    }
}
