//
//  VTPetObstacleAvoidanceControlCapabilityAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTPetObstacleAvoidanceControlCapabilityActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTPetObstacleAvoidanceControlCapabilityAction: Encodable, Hashable {
    let action: VTPetObstacleAvoidanceControlCapabilityActionType
}
