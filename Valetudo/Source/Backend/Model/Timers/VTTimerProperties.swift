//
//  VTTimerProperties.swift
//  Valetudo
//
//  Created by David Klopp on 12.04.26.
//

struct VTTimersProperties: Decodable, Sendable {
    let supportedActions: [VTTimer.Action.ActionType]
    let supportedPreActions: [VTTimer.PreAction.PreActionType]
}
