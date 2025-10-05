//
//  VTLogLevel.swift
//  Valetudo
//
//  Created by David Klopp on 04.10.25.
//
import Foundation

struct VTLogLevel: Decodable, Sendable {
    let current: String
    let presets: [String]
}
