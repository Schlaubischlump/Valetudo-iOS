//
//  VTRangeDimensions.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTRangeDimension: Decodable, Sendable, Equatable, Hashable {
    public let min: Int
    public let max: Int
    public let mid: Int
    public let avg: Int?
}
