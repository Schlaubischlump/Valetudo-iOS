//
//  VTConsumableType.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public enum VTConsumableType: String, Codable, Sendable, Describable {
    case brush, filter, cleaning, mop, detergent

    public var description: String {
        switch self {
        case .brush: "BRUSH".localized()
        case .cleaning: "CLEANING".localized()
        case .detergent: "DETERGENT".localized()
        case .filter: "FILTER".localized()
        case .mop: "MOP".localized()
        }
    }
}
