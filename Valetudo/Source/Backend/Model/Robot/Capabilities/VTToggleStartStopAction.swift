//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTToggleStartStopActionType: String, Encodable, Hashable {
    case start
    case stop
}

struct VTToggleStartStopAction: Encodable, Hashable {
    let action: VTToggleStartStopActionType
}
