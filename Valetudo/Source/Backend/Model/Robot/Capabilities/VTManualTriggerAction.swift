//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation


struct VTManualTriggerAction: Encodable, Hashable, Sendable  {
    let action = "trigger"

    enum CodingKeys: String, CodingKey {
        case action
    }
}
