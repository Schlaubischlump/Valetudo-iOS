//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTMopDockCleanToggleStartStopActionType: String, Encodable, Hashable {
    case start
    case stop
}

struct VTMopDockCleanToggleStartStopAction: Encodable, Hashable {
    let action: VTMopDockCleanToggleStartStopActionType
}
