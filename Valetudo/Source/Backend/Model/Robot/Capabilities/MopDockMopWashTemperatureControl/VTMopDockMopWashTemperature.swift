//
//  VTMopDockMopWashTemperature.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public enum VTMopDockMopWashTemperature: String, Codable, Sendable, Hashable {
    case cold
    case warm
    case hot
    case scalding
    case boiling
}

extension VTMopDockMopWashTemperature: Describable {
    public var description: String {
        switch self {
        case .cold:
            "MOP_WASH_TEMPERATURE_COLD".localized()
        case .warm:
            "MOP_WASH_TEMPERATURE_WARM".localized()
        case .hot:
            "MOP_WASH_TEMPERATURE_HOT".localized()
        case .scalding:
            "MOP_WASH_TEMPERATURE_SCALDING".localized()
        case .boiling:
            "MOP_WASH_TEMPERATURE_BOILING".localized()
        }
    }
}
