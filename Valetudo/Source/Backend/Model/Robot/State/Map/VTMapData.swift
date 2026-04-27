//
//  VTMapParser.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//
import Foundation

public struct VTMapData: Decodable, Sendable {
    public let size: VTSize
    public let pixelSize: Int
    public let layers: [VTLayer]
    public let entities: [VTEntity]
    public let metaData: VTMetaData

    var segmentLayer: [VTLayer] {
        layers.filter { $0.type == .segment }
    }
}

extension VTMapData: Equatable {}
