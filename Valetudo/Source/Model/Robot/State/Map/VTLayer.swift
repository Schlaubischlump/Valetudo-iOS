//
//  VTLayer.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTLayer: Decodable {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let type: VTLayerType
    public let pixels: [Int]
    public let compressedPixels: [Int]?
    public let dimensions: VTDimensions
    
    public var active: Bool? { metaData["active"]?.boolValue }
    public var source: String? { metaData["source"]?.stringValue }
    public var area: Int? { metaData["area"]?.intValue }
    public var name: String? { metaData["name"]?.stringValue }
    public var segmentId: String? { metaData["segmentId"]?.stringValue }
}

extension VTLayer: Equatable, Hashable {
    public static func == (lhs: VTLayer, rhs: VTLayer) -> Bool {
        guard let lhsId = lhs.segmentId, let rhsId = rhs.segmentId else { return false }
        return lhsId == rhsId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(segmentId)
    }
}
