//
//  VTEntity.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTEntity: Decodable, Sendable {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let type: VTEntityType
    public let points: [Int]

    var label: String? {
        metaData["label"]?.stringValue
    }

    var id: String? {
        metaData["id"]?.stringValue
    }
}

extension VTEntity: Equatable {}
