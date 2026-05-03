//
//  VTVirtualWallPoints.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTVirtualWallPoints: Codable, Hashable, Sendable {
    public let pA: VTMapCoordinate
    public let pB: VTMapCoordinate

    public init(pA: VTMapCoordinate, pB: VTMapCoordinate) {
        self.pA = pA
        self.pB = pB
    }
}
