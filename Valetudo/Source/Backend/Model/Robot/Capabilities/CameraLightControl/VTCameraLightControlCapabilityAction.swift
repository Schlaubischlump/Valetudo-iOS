///
///  VTCameraLightControlCapabilityAction.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTCameraLightControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTCameraLightControlCapabilityAction: Encodable, Hashable {
    let action: VTCameraLightControlCapabilityActionType
}
