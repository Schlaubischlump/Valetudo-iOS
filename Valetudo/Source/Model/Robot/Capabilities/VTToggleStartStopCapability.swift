//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

public enum VTToggleStartStopCapabilityType: String, Encodable {
    case start = "start"
    case stop  = "stop"
}

public struct VTToggleStartStopCapability: Encodable {
    let action: VTToggleStartStopCapabilityType

    enum CodingKeys: String, CodingKey {
        case action
    }
}
