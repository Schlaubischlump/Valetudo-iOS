//
//  VTLayer + Drawing.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import CoreGraphics
import Foundation

extension VTLayer {
    private static let roomPalette: [CGColor] = [
        CGColor(red: 0.92, green: 0.49, blue: 0.45, alpha: 1.0), // Soft Coral / Salmon
        CGColor(red: 0.30, green: 0.78, blue: 0.84, alpha: 1.0), // Bright Sky Blue / Cyan
        CGColor(red: 0.95, green: 0.73, blue: 0.33, alpha: 1.0), // Golden Yellow / Amber
        CGColor(red: 0.66, green: 0.49, blue: 0.86, alpha: 1.0), // Soft Lavender / Purple
        CGColor(red: 0.55, green: 0.78, blue: 0.35, alpha: 1.0), // Light Apple Green
        CGColor(red: 0.90, green: 0.46, blue: 0.72, alpha: 1.0), // Rose Pink
        CGColor(red: 0.36, green: 0.72, blue: 0.62, alpha: 1.0), // Muted Teal / Sage
        CGColor(red: 0.95, green: 0.58, blue: 0.35, alpha: 1.0), // Soft Orange / Peach
        CGColor(red: 0.42, green: 0.56, blue: 0.88, alpha: 1.0), // Cornflower Blue
        CGColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.0), // Medium Gray
        CGColor(red: 0.75, green: 0.35, blue: 0.30, alpha: 1.0), // Terracotta / Brick Red
        CGColor(red: 0.25, green: 0.65, blue: 0.95, alpha: 1.0), // Vivid Azure Blue
        CGColor(red: 0.98, green: 0.80, blue: 0.50, alpha: 1.0), // Pale Apricot / Wheat
        CGColor(red: 0.50, green: 0.40, blue: 0.75, alpha: 1.0), // Deep Periwinkle / Violet
        CGColor(red: 0.65, green: 0.85, blue: 0.40, alpha: 1.0), // Chartreuse / Lime Green
        CGColor(red: 0.85, green: 0.40, blue: 0.60, alpha: 1.0), // Raspberry Pink
        CGColor(red: 0.30, green: 0.60, blue: 0.55, alpha: 1.0), // Deep Sea Green
        CGColor(red: 0.98, green: 0.65, blue: 0.40, alpha: 1.0), // Cantaloupe / Light Orange
        CGColor(red: 0.35, green: 0.50, blue: 0.80, alpha: 1.0), // Steel Blue
        CGColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0), // Dark Gray
    ]

    // MARK: - Ordered assignment state

    @MainActor private static var assignment: [String: Int] = [:]
    @MainActor private static var nextIndex: Int = 0

    // MARK: - Public API

    @MainActor
    public var fillColor: CGColor? {
        switch type {
        case .segment:
            let index = Self.colorIndex(for: segmentId ?? name ?? "")
            return Self.roomPalette[index]
        case .wall:
            return .black
        case .floor:
            return nil
        }
    }

    // MARK: - Core logic (NO hashing)

    @MainActor
    private static func colorIndex(for id: String) -> Int {
        // already assigned → stable reuse
        if let existing = assignment[id] {
            return existing
        }

        // assign next palette slot in discovery order
        let index = nextIndex

        assignment[id] = index

        nextIndex += 1
        if nextIndex >= roomPalette.count {
            nextIndex = 0 // wrap (round-robin reuse)
        }

        return index
    }

    func pixelData() -> [CGPoint] {
        guard let compressedPixels else { return [] }
        return stride(from: 0, to: compressedPixels.count, by: 3)
            .flatMap { i in
                let xStart = compressedPixels[i]
                let y = compressedPixels[i + 1]
                let count = compressedPixels[i + 2]
                return (0 ..< count).map { CGPoint(x: xStart + $0, y: y) }
            }
    }
}

public extension VTMaterial {
    var color: CGColor? {
        .lightGray.copy(alpha: 0.2)
    }
}
