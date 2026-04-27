//
//  VTManualControlCapabilityState.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import Foundation

struct VTManualControlState: Decodable, Hashable, Sendable  {
    let enabled: Bool?
    let supportedMovementCommands: [VTMoveDirection]?
}
