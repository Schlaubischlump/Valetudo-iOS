//
//  VTAutoEmptyDockAutoEmptyDuration.swift
//  Valetudo
//

import Foundation

public enum VTAutoEmptyDockAutoEmptyDuration: String, Codable, Sendable, Hashable {
    case auto
    case short
    case medium
    case long
}

extension VTAutoEmptyDockAutoEmptyDuration: Describable {
    public var description: String {
        switch self {
        case .auto:
            "AUTO_EMPTY_DURATION_AUTO".localized()
        case .short:
            "AUTO_EMPTY_DURATION_SHORT".localized()
        case .medium:
            "AUTO_EMPTY_DURATION_MEDIUM".localized()
        case .long:
            "AUTO_EMPTY_DURATION_LONG".localized()
        }
    }
}
