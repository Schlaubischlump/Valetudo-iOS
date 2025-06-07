//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

public enum VTToggleManualTriggerCapabilityType: String, Encodable {
    case start = "start"
    case stop  = "stop"
}

public struct VTToggleManualTriggerCapability: Encodable {
    let action: VTToggleManualTriggerCapabilityType

    enum CodingKeys: String, CodingKey {
        case action
    }
}
