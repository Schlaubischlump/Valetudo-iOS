///
///  VTFloorMaterialDirectionAwareNavigationControlCapabilityAction.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTFloorMaterialDirectionAwareNavigationControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTFloorMaterialDirectionAwareNavigationControlCapabilityAction: Encodable, Hashable {
    let action: VTFloorMaterialDirectionAwareNavigationControlCapabilityActionType
}
