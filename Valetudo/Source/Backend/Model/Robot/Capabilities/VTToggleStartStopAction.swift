//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTToggleStartStopActionType: String, Encodable, Hashable, Sendable {
    case start = "start"
    case stop  = "stop"
}

struct VTToggleStartStopAction: Encodable, Hashable, Sendable{
    let action: VTToggleStartStopActionType
}
