//
//  CGSize + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    func clamped(to bounds: CGRect?) -> CGRect {
        guard let bounds else { return self }

        let clampedWidth = min(width, bounds.width)
        let clampedHeight = min(height, bounds.height)
        let minX = bounds.minX
        let maxX = bounds.maxX - clampedWidth
        let minY = bounds.minY
        let maxY = bounds.maxY - clampedHeight

        return CGRect(
            x: min(max(origin.x, minX), maxX),
            y: min(max(origin.y, minY), maxY),
            width: clampedWidth,
            height: clampedHeight
        )
    }
}
