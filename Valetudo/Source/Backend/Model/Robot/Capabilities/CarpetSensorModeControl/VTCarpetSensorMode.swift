//
//  VTCarpetSensorMode.swift
//  Valetudo
//

import Foundation

public enum VTCarpetSensorMode: String, Codable, Sendable, Hashable {
    case off
    case avoid
    case lift
    case detach
}

extension VTCarpetSensorMode: Describable {
    public var description: String {
        switch self {
        case .off:
            "CARPET_SENSOR_OFF".localized()
        case .avoid:
            "CARPET_SENSOR_AVOID".localized()
        case .lift:
            "CARPET_SENSOR_LIFT".localized()
        case .detach:
            "CARPET_SENSOR_DETACH".localized()
        }
    }
}
