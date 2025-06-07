//
//  VTLayer + Drawing.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation
import CoreGraphics

extension VTLayer {
    public var color: CGColor { CGColor.from(text: segmentId ?? "") }
    
    func pixelData() -> [CGPoint] {
        guard let compressedPixels = compressedPixels else { return [] }
        return stride(from: 0, to: compressedPixels.count, by: 3)
            .flatMap { i in
                let xStart = compressedPixels[i]
                let y = compressedPixels[i + 1]
                let count = compressedPixels[i + 2]
                return (0..<count).map { CGPoint(x: xStart + $0, y: y) }
            }
    }
}
