//
//  VTMetaData.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTMetaData: Decodable {
    public let version: Double
}

extension VTMetaData: Equatable {}
