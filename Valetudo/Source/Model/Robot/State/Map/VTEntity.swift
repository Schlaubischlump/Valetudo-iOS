//
//  VTEntity.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTEntity: Decodable {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let type: VTEntityType
    public let points: [Int]
}

extension VTEntity: Equatable {}
