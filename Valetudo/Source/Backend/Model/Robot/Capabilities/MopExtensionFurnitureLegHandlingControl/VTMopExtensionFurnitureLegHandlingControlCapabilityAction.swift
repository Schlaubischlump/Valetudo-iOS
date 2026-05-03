//
//  VTMopExtensionFurnitureLegHandlingControlCapabilityAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTMopExtensionFurnitureLegHandlingControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTMopExtensionFurnitureLegHandlingControlCapabilityAction: Encodable, Hashable {
    let action: VTMopExtensionFurnitureLegHandlingControlCapabilityActionType
}
