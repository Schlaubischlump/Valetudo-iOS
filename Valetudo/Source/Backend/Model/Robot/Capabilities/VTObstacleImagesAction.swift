//
//  VTObstacleImagesAction.swift
//  Valetudo
//
//  Created by David Klopp on 26.04.26.
//
import Foundation

enum VTObstacleImagesActionType: String, Encodable, Hashable {
    case enabled
    case disable
}

struct VTObstacleImagesAction: Encodable, Hashable {
    let action: VTObstacleImagesActionType
}
