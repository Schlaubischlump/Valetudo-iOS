//
//  VTRectangularZonePoints.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTRectangularZonePoints: Codable, Hashable, Sendable {
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
