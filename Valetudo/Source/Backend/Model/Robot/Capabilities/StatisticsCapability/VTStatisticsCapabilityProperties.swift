//
//  VTStatisticsCapabilityProperties.swift
//  Valetudo
//

import Foundation

public struct VTStatisticsCapabilityProperties: Decodable, Sendable, Hashable {
    let availableStatistics: [VTValetudoDataPointType]
}
