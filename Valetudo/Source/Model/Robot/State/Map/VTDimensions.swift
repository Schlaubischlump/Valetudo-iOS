//
//  VTDimensions.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation
import CoreGraphics

public struct VTDimensions: Decodable {
    public let x: VTRangeDimension
    public let y: VTRangeDimension
    public let pixelCount: Int
}
