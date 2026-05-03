//
//  VTVirtualWallPayload.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTVirtualWallPayload: Codable, Hashable, Sendable {
    public let points: VTVirtualWallPoints

    public init(points: VTVirtualWallPoints) {
        self.points = points
    }
}
