//
//  VTMappingPassAction.swift
//  Valetudo
//
//  Created by David Klopp on 27.04.26.
//

enum VTMappingPassActionType: String, Encodable, Hashable, Sendable {
    case startMapping = "start_mapping"
}

struct VTMappingPassAction: Encodable, Sendable, Hashable {
    let action: VTMappingPassActionType = .startMapping
}
