//
//  VTMapParser.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//
import CoreGraphics
import Foundation

public struct VTMapData: Decodable, Sendable {
    public let size: VTSize
    public let pixelSize: Int
    public let layers: [VTLayer]
    public let entities: [VTEntity]
    public let metaData: VTMetaData
    
    /// Computed property, not part of the decodable.
    let boundingRect: CGRect

    var segmentLayer: [VTLayer] {
        layers.filter { $0.type == .segment }
    }

    init(
        size: VTSize,
        pixelSize: Int,
        layers: [VTLayer],
        entities: [VTEntity],
        metaData: VTMetaData
    ) {
        self.size = size
        self.pixelSize = pixelSize
        self.layers = layers
        self.entities = entities
        self.metaData = metaData
        boundingRect = Self.computeBoundingRect(from: layers)
    }

    private enum CodingKeys: String, CodingKey {
        case size
        case pixelSize
        case layers
        case entities
        case metaData
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let size = try container.decode(VTSize.self, forKey: .size)
        let pixelSize = try container.decode(Int.self, forKey: .pixelSize)
        let layers = try container.decode([VTLayer].self, forKey: .layers)
        let entities = try container.decode([VTEntity].self, forKey: .entities)
        let metaData = try container.decode(VTMetaData.self, forKey: .metaData)
        self.init(
            size: size,
            pixelSize: pixelSize,
            layers: layers,
            entities: entities,
            metaData: metaData
        )
    }

    /// Returns the raw map-space bounds covered by the currently known layers.
    private static func computeBoundingRect(from layers: [VTLayer]) -> CGRect {
        var minPoint = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
        var maxPoint = CGPoint(x: -CGFloat.infinity, y: -CGFloat.infinity)

        for layer in layers {
            minPoint.x = min(CGFloat(layer.dimensions.x.min), minPoint.x)
            minPoint.y = min(CGFloat(layer.dimensions.y.min), minPoint.y)
            maxPoint.x = max(CGFloat(layer.dimensions.x.max), maxPoint.x)
            maxPoint.y = max(CGFloat(layer.dimensions.y.max), maxPoint.y)
        }

        return CGRect(
            x: minPoint.x,
            y: minPoint.y,
            width: maxPoint.x - minPoint.x,
            height: maxPoint.y - minPoint.y
        )
    }
}

extension VTMapData: Equatable {}
