//
//  VTPersistentMapControlCapabilityAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTPersistentMapControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTPersistentMapControlCapabilityAction: Encodable, Hashable {
    let action: VTPersistentMapControlCapabilityActionType
}
