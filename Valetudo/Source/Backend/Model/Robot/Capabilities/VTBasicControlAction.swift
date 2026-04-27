//
//  VT.swift
//  Valetudo
//
//  Created by David Klopp on 23.05.25.
//
import Foundation

enum VTBasicControlCapabilityActionType: String, Encodable, Hashable {
    case start
    case stop
    case pause
    case home
}

struct VTBasicControlAction: Encodable, Hashable {
    let action: VTBasicControlCapabilityActionType
}
