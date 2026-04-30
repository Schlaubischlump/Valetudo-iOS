//
//  VTMaterial.swift
//  Valetudo
//
//  Created by David Klopp on 29.09.25.
//

import Foundation

public enum VTMaterial: String, Codable, Sendable, Hashable {
    case generic
    case tile
    case wood
    case woodHorizontal = "wood_horizontal"
    case woodVertical = "wood_vertical"
}

extension VTMaterial: Describable {
    public var description: String {
        switch self {
        case .generic: "MATERIAL_GENERIC".localized()
        case .tile: "MATERIAL_TILE".localized()
        case .wood: "MATERIAL_WOOD".localized()
        case .woodHorizontal: "MATERIAL_WOOD_HORIZONTAL".localized()
        case .woodVertical: "MATERIAL_WOOD_VERTICAL".localized()
        }
    }
}
