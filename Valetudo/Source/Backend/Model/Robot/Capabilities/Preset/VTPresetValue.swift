//
//  VTPresetValue.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public enum VTPresetValue: String, Codable, Sendable, Describable {
    case off, min, low, medium, high, max, turbo, custom
    case vacuum, mop, vacuumAndMop = "vacuum_and_mop", vacuumThenMop = "vacuum_then_mop"

    public var description: String {
        switch self {
        case .off: "OFF".localized()
        case .min: "MIN".localized()
        case .low: "LOW".localized()
        case .medium: "MEDIUM".localized()
        case .high: "HIGH".localized()
        case .max: "MAX".localized()
        case .turbo: "TURBO".localized()
        case .custom: "CUSTOM".localized()
        case .vacuum: "VACUUM".localized()
        case .mop: "MOP".localized()
        case .vacuumAndMop: "VACUUM_AND_MOP".localized()
        case .vacuumThenMop: "VACUUM_THEN_MOP".localized()
        }
    }
}
