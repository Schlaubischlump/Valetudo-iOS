//
//  VTMopExtensionControlCapabilityAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTMopExtensionControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTMopExtensionControlCapabilityAction: Encodable, Hashable {
    let action: VTMopExtensionControlCapabilityActionType
}
