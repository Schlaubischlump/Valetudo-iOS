//
//  VTZoneCleaningAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTZoneCleaningActionType: String, Encodable, Hashable {
    case clean
}

struct VTZoneCleaningAction: Encodable, Hashable {
    let action: VTZoneCleaningActionType
    let zones: [VTZoneCleaningZone]
    let iterations: Int
}
