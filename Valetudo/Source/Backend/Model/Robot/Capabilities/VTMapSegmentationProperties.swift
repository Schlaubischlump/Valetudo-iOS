//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

public struct VTMapSegmentationIterationCount: Decodable, Hashable, Sendable {
    let min: Int
    let max: Int
}

public struct VTMapSegmentationProperties: Decodable, Hashable, Sendable {
    let iterationCount: VTMapSegmentationIterationCount
    let customOrderSupport: Bool
}
