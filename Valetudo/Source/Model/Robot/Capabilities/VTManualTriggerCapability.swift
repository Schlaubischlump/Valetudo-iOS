//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation


public struct VTManualTriggerCapability: Encodable {
    let action = "trigger"

    enum CodingKeys: String, CodingKey {
        case action
    }
}
