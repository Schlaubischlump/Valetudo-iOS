//
//  VTAutoEmptyDockAutoEmptyInterval.swift
//  Valetudo
//

import Foundation

public enum VTAutoEmptyDockAutoEmptyInterval: String, Codable, Sendable, Hashable {
    case off
    case infrequent
    case normal
    case frequent
}

extension VTAutoEmptyDockAutoEmptyInterval: Describable {
    public var description: String {
        switch self {
        case .off:
            "DOCK_AUTO_EMPTY_OFF".localized()
        case .infrequent:
            "DOCK_AUTO_EMPTY_INFREQUENT".localized()
        case .normal:
            "DOCK_AUTO_EMPTY_NORMAL".localized()
        case .frequent:
            "DOCK_AUTO_EMPTY_FREQUENT".localized()
        }
    }
}
