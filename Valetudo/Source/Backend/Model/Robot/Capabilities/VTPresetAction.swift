//
//  VTPresetCapability.swift
//  Valetudo
//
//  Created by David Klopp on 03.06.25.
//

public struct VTPresetAction: Encodable {
    let name: VTPresetValue

    enum CodingKeys: String, CodingKey {
        case name
    }
}
