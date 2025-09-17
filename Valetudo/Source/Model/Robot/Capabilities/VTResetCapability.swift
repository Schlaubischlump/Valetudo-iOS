//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation


public struct VTResetCapability: Encodable {
    let action = "reset"

    enum CodingKeys: String, CodingKey {
        case action
    }
}
