///
///  VTMopDockMopAutoDryingControlCapabilityAction.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTMopDockMopAutoDryingControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTMopDockMopAutoDryingControlCapabilityAction: Encodable, Hashable {
    let action: VTMopDockMopAutoDryingControlCapabilityActionType
}
