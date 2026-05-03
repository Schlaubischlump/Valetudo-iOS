//
//  VTConsumableStateProperties.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTConsumableStateProperties: Decodable, Sendable, Equatable {
    public let type: VTConsumableType
    public let subType: VTConsumableSubType
    public let unit: VTConsumableUnit
    public let maxValue: Double?
}
