//
//  VTMapSegment.swift
//  Valetudo
//
//  Created by David Klopp on 30.04.26.
//

public struct VTMapSegment: Decodable, Sendable, Hashable {
    let __class: String
    let metaData: [String: VTAnyCodable]
    let id: String
    let name: String
    let material: VTMaterial
}
