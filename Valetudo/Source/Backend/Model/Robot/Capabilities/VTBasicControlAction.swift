//
//  VT.swift
//  Valetudo
//
//  Created by David Klopp on 23.05.25.
//
import Foundation

public enum VTBasicControlCapabilityActionType: String, Encodable, Hashable, Sendable {
    case start  = "start"
    case stop   = "stop"
    case pause  = "pause"
    case home   = "home"
}

public struct VTBasicControlAction: Encodable, Hashable, Sendable {
    let action: VTBasicControlCapabilityActionType

    enum CodingKeys: String, CodingKey {
        case action
    }
}
