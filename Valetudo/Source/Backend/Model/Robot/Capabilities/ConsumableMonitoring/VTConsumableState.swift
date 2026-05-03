//
//  VTConsumableState.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTConsumableState: Decodable, Equatable, Sendable {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let type: VTConsumableType
    public let subType: VTConsumableSubType
    public let remaining: VTConsumableRemaining
}
