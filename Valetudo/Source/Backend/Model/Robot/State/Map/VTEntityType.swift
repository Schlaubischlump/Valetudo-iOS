//
//  VTEntityType.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public enum VTEntityType: Decodable, Sendable, Hashable {
    case charger_location
    case robot_position
    case go_to_target
    case virtual_wall
    case path
    case predicted_path
    case active_zone
    case no_go_area
    case no_mop_area
    case obstacle
    case carpet
    case threshold
    case curtain
    case ramp
    case unknown(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = switch rawValue {
        case "charger_location": .charger_location
        case "robot_position": .robot_position
        case "go_to_target": .go_to_target
        case "virtual_wall": .virtual_wall
        case "path": .path
        case "predicted_path": .predicted_path
        case "active_zone": .active_zone
        case "no_go_area": .no_go_area
        case "no_mop_area": .no_mop_area
        case "obstacle": .obstacle
        case "carpet": .carpet
        case "threshold": .threshold
        case "curtain": .curtain
        case "ramp": .ramp
        default: .unknown(rawValue)
        }
    }
}
