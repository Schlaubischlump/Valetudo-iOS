//
//  VTMaterial.swift
//  Valetudo
//
//  Created by David Klopp on 29.09.25.
//

import Foundation

public enum VTMaterial: Codable, Sendable, Hashable {
    case generic
    case tile
    case wood
    case woodHorizontal
    case woodVertical
    case carpet
    case carpetLow
    case carpetHigh
    case unknown(String)

    public init(rawValue: String) {
        self = switch rawValue {
        case "generic": .generic
        case "tile": .tile
        case "wood": .wood
        case "wood_horizontal": .woodHorizontal
        case "wood_vertical": .woodVertical
        case "carpet": .carpet
        case "carpet_low": .carpetLow
        case "carpet_high": .carpetHigh
        default: .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .generic: "generic"
        case .tile: "tile"
        case .wood: "wood"
        case .woodHorizontal: "wood_horizontal"
        case .woodVertical: "wood_vertical"
        case .carpet: "carpet"
        case .carpetLow: "carpet_low"
        case .carpetHigh: "carpet_high"
        case let .unknown(value): value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(rawValue: container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension VTMaterial: Describable {
    public var description: String {
        switch self {
        case .generic: "MATERIAL_GENERIC".localized()
        case .tile: "MATERIAL_TILE".localized()
        case .wood: "MATERIAL_WOOD".localized()
        case .woodHorizontal: "MATERIAL_WOOD_HORIZONTAL".localized()
        case .woodVertical: "MATERIAL_WOOD_VERTICAL".localized()
        case .carpet: "MATERIAL_CARPET".localized()
        case .carpetLow: "MATERIAL_CARPET_LOW".localized()
        case .carpetHigh: "MATERIAL_CARPET_HIGH".localized()
        case let .unknown(value): value
        }
    }
}
