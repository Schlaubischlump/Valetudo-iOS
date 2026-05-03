//
//  VTMopTwistControlCapabilityAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTMopTwistControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTMopTwistControlCapabilityAction: Encodable, Hashable {
    let action: VTMopTwistControlCapabilityActionType
}
