//
//  VTLogLevel.swift
//  Valetudo
//
//  Created by David Klopp on 04.10.25.
//
import Foundation

final class VTLogLevel: Codable, Sendable {
    let current: String
    let presets: [String]
}
