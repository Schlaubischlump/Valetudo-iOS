//
//  VTObstacleImagesAction.swift
//  Valetudo
//
//  Created by David Klopp on 26.04.26.
//
import Foundation

enum VTObstacleImagesActionType: String, Encodable, Hashable, Sendable {
    case enabled
    case disable
}

struct VTObstacleImagesAction: Encodable, Hashable, Sendable {
    let action: VTObstacleImagesActionType
}
