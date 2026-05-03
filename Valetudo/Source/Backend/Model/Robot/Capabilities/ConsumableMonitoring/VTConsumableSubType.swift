//
//  VTConsumableSubType.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public enum VTConsumableSubType: String, Codable, Sendable, Describable {
    case main, sideRight = "side_right", sensor, all, dock

    public var description: String {
        switch self {
        case .all: "ALL".localized()
        case .dock: "DOCK".localized()
        case .main: "MAIN".localized()
        case .sensor: "SENSOR".localized()
        case .sideRight: "RIGHT".localized()
        }
    }
}
