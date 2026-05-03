//
//  VTObstacleAvoidanceControlCapabilityAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTObstacleAvoidanceControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTObstacleAvoidanceControlCapabilityAction: Encodable, Hashable {
    let action: VTObstacleAvoidanceControlCapabilityActionType
}
