///
///  VTCarpetModeControlCapabilityAction.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTCarpetModeControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTCarpetModeControlCapabilityAction: Encodable, Hashable {
    let action: VTCarpetModeControlCapabilityActionType
}
