//
//  VTPresetType.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public enum VTPresetType: String, Codable, Sendable, Describable {
    case fanSpeed = "fan_speed"
    case waterGrade = "water_grade"
    case operationMode = "operation_mode"

    public var description: String {
        switch self {
        case .waterGrade: "WATER_GRADE".localized()
        case .fanSpeed: "FAN_SPEED".localized()
        case .operationMode: "OPERATION_MODE".localized()
        }
    }
}
