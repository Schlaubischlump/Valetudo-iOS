//
//  VTCleanRoute.swift
//  Valetudo
//

import Foundation

public enum VTCleanRoute: String, Codable, Sendable, Hashable {
    case normal
    case quick
    case intensive
    case deep
}

extension VTCleanRoute: Describable {
    public var description: String {
        switch self {
        case .normal:
            "CLEAN_ROUTE_NORMAL".localized()
        case .quick:
            "CLEAN_ROUTE_QUICK".localized()
        case .intensive:
            "CLEAN_ROUTE_INTENSIVE".localized()
        case .deep:
            "CLEAN_ROUTE_DEEP".localized()
        }
    }
}
