//
//  VTMopDockMopDryingDuration.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public enum VTMopDockMopDryingDuration: String, Codable, Sendable, Hashable {
    case twoHours = "2h"
    case threeHours = "3h"
    case fourHours = "4h"
    case cold
}

extension VTMopDockMopDryingDuration: Describable {
    public var description: String {
        switch self {
        case .twoHours:
            "MOP_DRYING_TIME_TWO_HOURS".localized()
        case .threeHours:
            "MOP_DRYING_TIME_THREE_HOURS".localized()
        case .fourHours:
            "MOP_DRYING_TIME_FOUR_HOURS".localized()
        case .cold:
            "MOP_DRYING_TIME_COLD".localized()
        }
    }
}
