//
//  VTPatternFactory.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import CoreGraphics
import Foundation

enum VTPatternFactory {
    // MARK: - Helper

    private static func getBounds(from pts: [CGPoint]) -> (minX: Int, maxX: Int, minY: Int, maxY: Int)? {
        guard !pts.isEmpty else { return nil }
        return (
            minX: Int(ceil(pts.map(\.x).min()!)),
            maxX: Int(floor(pts.map(\.x).max()!)),
            minY: Int(ceil(pts.map(\.y).min()!)),
            maxY: Int(floor(pts.map(\.y).max()!))
        )
    }

    // MARK: - Carpet (aka. Grid)

    static func makeCarpetPattern(withPoints pts: [CGPoint], lineWidth: CGFloat) -> CGPath {
        let path = CGMutablePath()

        guard let bounds = getBounds(from: pts) else { return path }
        let spacing = Int(0.5 + lineWidth)

        let padX = (bounds.maxX - bounds.minX) % spacing
        let padY = (bounds.maxY - bounds.minY) % spacing

        for x in stride(from: bounds.minX, through: bounds.maxX + padX, by: spacing) {
            path.move(to: CGPoint(x: x, y: bounds.minY))
            path.addLine(to: CGPoint(x: x, y: bounds.maxY + padY))
        }

        for y in stride(from: bounds.minY, through: bounds.maxY + padY, by: spacing) {
            path.move(to: CGPoint(x: bounds.minX, y: y))
            path.addLine(to: CGPoint(x: bounds.maxX + padX, y: y))
        }

        return path
    }

    // MARK: - Tile

    static func makeTilePattern(withPoints pts: [CGPoint], tileSize: Int = 6) -> CGPath {
        let path = CGMutablePath()

        guard let bounds = getBounds(from: pts) else { return path }

        let startX = ((bounds.minX / tileSize) - 1) * tileSize
        for x in stride(from: startX, to: bounds.maxX + tileSize * 2, by: tileSize) {
            path.move(to: CGPoint(x: x, y: bounds.minY))
            path.addLine(to: CGPoint(x: x, y: bounds.maxY))
        }

        let startY = ((bounds.minY / tileSize) - 1) * tileSize
        for y in stride(from: startY, to: bounds.maxY + tileSize * 2, by: tileSize) {
            path.move(to: CGPoint(x: bounds.minX, y: y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: y))
        }

        return path
    }

    // MARK: - Wood (Horizontal / Vertical)

    static func makeVerticalWoodPattern(withPoints pts: [CGPoint], plankWidth: Int = 5, plankLength: Int = 24) -> CGPath {
        let path = CGMutablePath()

        guard let bounds = getBounds(from: pts) else { return path }
        let jointOffset = plankLength / 2

        let startX = ((bounds.minX / plankWidth) - 1) * plankWidth

        for x in stride(from: startX, to: bounds.maxX + plankWidth, by: plankWidth) {
            // Main vertical plank line
            path.move(to: CGPoint(x: x, y: bounds.minY))
            path.addLine(to: CGPoint(x: x, y: bounds.maxY))

            let stripIndex = Int(floor(Double(x) / Double(plankWidth)))
            let isEvenStrip = stripIndex % 2 == 0
            let currentJointPos = isEvenStrip ? 0 : jointOffset

            let startY = ((bounds.minY / plankLength) - 1) * plankLength + currentJointPos

            // Horizontal joint lines
            for y in stride(from: startY, to: bounds.maxY + plankLength, by: plankLength) {
                if y >= bounds.minY, y <= bounds.maxY {
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x + plankWidth, y: y))
                }
            }
        }
        return path
    }

    static func makeHorizontalWoodPattern(withPoints pts: [CGPoint], plankWidth: Int = 5, plankLength: Int = 24) -> CGPath {
        let path = CGMutablePath()

        guard let bounds = getBounds(from: pts) else { return path }
        let jointOffset = plankLength / 2

        let startY = ((bounds.minY / plankWidth) - 1) * plankWidth

        for y in stride(from: startY, to: bounds.maxY + plankWidth, by: plankWidth) {
            // Main horizontal plank line
            path.move(to: CGPoint(x: bounds.minX, y: y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: y))

            // Calculate joint alignment for this row
            let stripIndex = Int(floor(Double(y) / Double(plankWidth)))
            let isEvenStrip = stripIndex % 2 == 0
            let currentJointPos = isEvenStrip ? 0 : jointOffset

            let startX = ((bounds.minX / plankLength) - 1) * plankLength + currentJointPos

            // Vertical joint lines
            for x in stride(from: startX, to: bounds.maxX + plankLength, by: plankLength) {
                if x >= bounds.minX, x <= bounds.maxX {
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x, y: y + plankWidth))
                }
            }
        }
        return path
    }

    // MARK: - Chevron

    static func makeChevronPattern(withPoints pts: [CGPoint], plankWidth: Int = 4, sectionWidth: Int = 8) -> CGPath {
        let path = CGMutablePath()

        guard let bounds = getBounds(from: pts) else { return path }

        let startColX = ((bounds.minX / sectionWidth) - 1) * sectionWidth

        // Iterate through columns of zig-zags
        for colX in stride(from: startColX, to: bounds.maxX + sectionWidth, by: sectionWidth) {
            let stripIndex = Int(floor(Double(colX) / Double(sectionWidth)))
            let isZig = stripIndex % 2 == 0

            let colMinX = colX
            let colMaxX = colX + sectionWidth

            if isZig {
                // Math equivalent: (x + y) % plankWidth == 0
                let minK = ((colMinX + bounds.minY) / plankWidth) - 1
                let maxK = ((colMaxX + bounds.maxY) / plankWidth) + 1
                for k in minK ... maxK {
                    let c = k * plankWidth
                    path.move(to: CGPoint(x: colMinX, y: c - colMinX))
                    path.addLine(to: CGPoint(x: colMaxX, y: c - colMaxX))
                }
            } else {
                // Math equivalent: (x - y) % plankWidth == 0
                let minK = ((colMinX - bounds.maxY) / plankWidth) - 1
                let maxK = ((colMaxX - bounds.minY) / plankWidth) + 1
                for k in minK ... maxK {
                    let c = k * plankWidth
                    path.move(to: CGPoint(x: colMinX, y: colMinX - c))
                    path.addLine(to: CGPoint(x: colMaxX, y: colMaxX - c))
                }
            }
        }
        return path
    }

    // MARK: - Parquet

    static func makeParquetPattern(withPoints pts: [CGPoint], blockSize: Int = 8, plankGap: Int = 2) -> CGPath {
        let path = CGMutablePath()

        guard let bounds = getBounds(from: pts) else { return path }

        // 1. Draw block borders
        let startX = ((bounds.minX / blockSize) - 1) * blockSize
        for x in stride(from: startX, to: bounds.maxX + blockSize, by: blockSize) {
            path.move(to: CGPoint(x: x, y: bounds.minY))
            path.addLine(to: CGPoint(x: x, y: bounds.maxY))
        }

        let startY = ((bounds.minY / blockSize) - 1) * blockSize
        for y in stride(from: startY, to: bounds.maxY + blockSize, by: blockSize) {
            path.move(to: CGPoint(x: bounds.minX, y: y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: y))
        }

        // 2. Draw inner alternating planks
        let startGridX = (bounds.minX / blockSize) - 1
        let endGridX = (bounds.maxX / blockSize) + 1
        let startGridY = (bounds.minY / blockSize) - 1
        let endGridY = (bounds.maxY / blockSize) + 1

        for gX in startGridX ... endGridX {
            for gY in startGridY ... endGridY {
                let isVerticalBlock = (gX + gY) % 2 == 0
                let blockMinX = gX * blockSize
                let blockMaxX = (gX + 1) * blockSize
                let blockMinY = gY * blockSize
                let blockMaxY = (gY + 1) * blockSize

                if isVerticalBlock {
                    for lx in stride(from: blockMinX + plankGap, to: blockMaxX, by: plankGap) {
                        path.move(to: CGPoint(x: lx, y: blockMinY))
                        path.addLine(to: CGPoint(x: lx, y: blockMaxY))
                    }
                } else {
                    for ly in stride(from: blockMinY + plankGap, to: blockMaxY, by: plankGap) {
                        path.move(to: CGPoint(x: blockMinX, y: ly))
                        path.addLine(to: CGPoint(x: blockMaxX, y: ly))
                    }
                }
            }
        }
        return path
    }
}
