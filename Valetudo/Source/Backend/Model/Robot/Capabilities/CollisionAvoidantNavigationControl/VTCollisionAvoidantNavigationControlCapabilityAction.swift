///
///  VTCollisionAvoidantNavigationControlCapabilityAction.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTCollisionAvoidantNavigationControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTCollisionAvoidantNavigationControlCapabilityAction: Encodable, Hashable {
    let action: VTCollisionAvoidantNavigationControlCapabilityActionType
}
