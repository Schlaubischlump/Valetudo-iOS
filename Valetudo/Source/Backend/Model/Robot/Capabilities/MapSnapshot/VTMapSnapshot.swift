//
//  VTMapSnapshot.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation

public struct VTMapSnapshot: Decodable, Sendable {
    let id: String
    let timestamp: Date
    let map: VTMapData
    let metaData: [String: VTAnyCodable]
}
