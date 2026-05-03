//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTMopDockDryToggleStartStopActionType: String, Encodable, Hashable {
    case start
    case stop
}

struct VTMopDockDryToggleStartStopAction: Encodable, Hashable {
    let action: VTMopDockDryToggleStartStopActionType
}
