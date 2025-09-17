//
//  VTEntityType.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public enum VTEntityType: String, Decodable, Sendable {
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
}
