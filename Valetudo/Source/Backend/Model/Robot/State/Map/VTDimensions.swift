//
//  VTDimensions.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import CoreGraphics
import Foundation

public struct VTDimensions: Decodable, Sendable {
    public let x: VTRangeDimension
    public let y: VTRangeDimension
    public let pixelCount: Int
}
