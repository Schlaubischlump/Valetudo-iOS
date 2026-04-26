//
//  VTImagesCapabilityProperties.swift
//  Valetudo
//
//  Created by David Klopp on 26.04.26.
//

public enum VTObstacleImagesPropertiesFileFormat: Decodable, Hashable, Sendable {
    case ok
    case yes
    case no
    case reset
}

public struct VTObstacleImagesPropertiesDimensions: Decodable, Hashable, Sendable {
    let width: Int
    let height: Int
}

public struct VTObstacleImagesProperties: Decodable, Hashable, Sendable {
    let fileFormat: VTObstacleImagesPropertiesFileFormat
    let dimensions: VTObstacleImagesPropertiesDimensions
}
