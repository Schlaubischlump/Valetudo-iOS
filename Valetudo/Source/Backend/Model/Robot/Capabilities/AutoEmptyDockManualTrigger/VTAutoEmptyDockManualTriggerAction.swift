//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTAutoEmptyDockManualTriggerActionType: String, Encodable, Hashable {
    case trigger
}

struct VTAutoEmptyDockManualTriggerAction: Encodable, Hashable {
    let action: VTAutoEmptyDockManualTriggerActionType = .trigger
}
