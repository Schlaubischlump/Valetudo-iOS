//
//  VTLayer.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTLayer: Decodable, Sendable {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let type: VTLayerType
    public let pixels: [Int]
    public let compressedPixels: [Int]?
    public let dimensions: VTDimensions

    public var material: VTMaterial {
        guard let materialString = metaData["material"]?.stringValue else { return .generic }
        return VTMaterial(rawValue: materialString) ?? .generic
    }

    public var active: Bool? {
        metaData["active"]?.boolValue
    }

    public var source: String? {
        metaData["source"]?.stringValue
    }

    public var area: Int? {
        metaData["area"]?.intValue
    }

    public var name: String? {
        metaData["name"]?.stringValue
    }

    public var segmentId: String? {
        metaData["segmentId"]?.stringValue
    }
}

extension VTLayer: Equatable, Hashable {}

extension VTLayer: Describable {
    public var description: String {
        name ?? segmentId ?? "UNKNOWN".localized()
    }
}
