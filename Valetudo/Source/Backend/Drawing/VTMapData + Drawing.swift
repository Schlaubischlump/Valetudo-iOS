//
//  VTMapData + Drawing.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics
import Foundation
import QuartzCore

extension VTMapData {
    private func calculatedBoundingRect() -> CGRect {
        var minPoint = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
        var maxPoint = CGPoint(x: -CGFloat.infinity, y: -CGFloat.infinity)
        for layer in layers {
            minPoint.x = min(CGFloat(layer.dimensions.x.min), minPoint.x)
            minPoint.y = min(CGFloat(layer.dimensions.y.min), minPoint.y)
            maxPoint.x = max(CGFloat(layer.dimensions.x.max), maxPoint.x)
            maxPoint.y = max(CGFloat(layer.dimensions.y.max), maxPoint.y)
        }
        return CGRect(
            x: minPoint.x,
            y: minPoint.y,
            width: maxPoint.x - minPoint.x,
            height: maxPoint.y - minPoint.y
        )
    }

    /// Check if a point is in a no-go area. We assume no-go areas to be always rectangular.
    @inline(__always) private func isPoint(_ point: CGPoint,
                                           boundedByX x: CGFloat,
                                           y: CGFloat,
                                           insideNoGoAreas noGoAreas: [VTEntity]) -> Bool
    {
        let pixelScale = CGFloat(pixelSize)

        for area in noGoAreas where area.type == .no_go_area {
            let pts = area.points
            guard pts.count >= 4 else { continue }

            // Transform all points once
            var minX = CGFloat.infinity
            var minY = CGFloat.infinity
            var maxX = -CGFloat.infinity
            var maxY = -CGFloat.infinity

            for i in stride(from: 0, to: pts.count, by: 2) {
                let p = CGPoint(x: pts[i], y: pts[i + 1])
                    .downScaledBy(x: pixelScale, y: pixelScale)
                    .insetBy(dx: x, dy: y)

                minX = min(minX, p.x)
                minY = min(minY, p.y)
                maxX = max(maxX, p.x)
                maxY = max(maxY, p.y)
            }

            // Simple rectangle containment check
            if point.x >= minX, point.x <= maxX, point.y >= minY, point.y <= maxY {
                return true
            }
        }

        return false
    }

    @MainActor
    private func drawRooms(in container: CALayer, boundedByX x: CGFloat, y: CGFloat, hideNoGoAreas: Bool) {
        let noGoAreas = entities.filter { $0.type == .no_go_area }

        for layer in layers {
            let path = CGMutablePath()

            let pixels = layer.pixelData().map { $0.insetBy(dx: x, dy: y) }

            for px in pixels {
                if hideNoGoAreas, isPoint(px, boundedByX: x, y: y, insideNoGoAreas: noGoAreas) {
                    continue
                }
                let rect = CGRect(origin: px, size: .one)
                path.addRect(rect)
            }

            guard !path.isEmpty else { continue }

            // 1.1. Fill room with color
            let shapeLayer = VTLayerShapeLayer(data: layer)
            shapeLayer.path = path
            shapeLayer.strokeColor = nil
            shapeLayer.fillColor = layer.fillColor
            container.addSublayer(shapeLayer)

            // 1.2 Apply Material pattern
            let patternPath: CGPath? = switch layer.material {
            case .generic: nil
            case .tile: VTPatternFactory.makeTilePattern(withPoints: pixels)
            case .wood: VTPatternFactory.makeChevronPattern(withPoints: pixels)
            case .woodHorizontal: VTPatternFactory.makeHorizontalWoodPattern(withPoints: pixels)
            case .woodVertical: VTPatternFactory.makeVerticalWoodPattern(withPoints: pixels)
            }

            if let patternPath {
                let patternLayer = CAShapeLayer()
                patternLayer.path = patternPath
                patternLayer.strokeColor = layer.material.color
                patternLayer.fillColor = nil
                patternLayer.lineWidth = 1.0

                // Mask the pattern to only draw exactly where the base layer exists
                let maskLayer = CAShapeLayer()
                maskLayer.path = path
                patternLayer.mask = maskLayer

                container.addSublayer(patternLayer)
            }
        }
    }

    private func drawIcon(for entity: VTEntity, boundedByX x: CGFloat, y: CGFloat, scale: CGFloat) -> VTEntityShapeLayer? {
        let shapeLayer = VTEntityShapeLayer(data: entity)

        guard let centerPoint = entity.centerPoint?.downScaledBy(x: scale, y: scale) else {
            fatalError("Expected a unique center point for entity: \(entity)")
        }

        guard let icon = entity.type.icon(center: centerPoint.insetBy(dx: x, dy: y)) else { return nil }
        let angleInRadians = entity.angleInDegree * (.pi / 180)
        shapeLayer.path = icon.rotated(by: angleInRadians)
        shapeLayer.fillColor = entity.type.color
        shapeLayer.strokeColor = entity.type.borderColor
        shapeLayer.lineWidth = entity.type.borderWidth
        return shapeLayer
    }

    private func drawPath(for entity: VTEntity, boundedByX x: CGFloat, y: CGFloat, scale: CGFloat) -> VTEntityShapeLayer? {
        let shapeLayer = VTEntityShapeLayer(data: entity)
        let points = entity.points

        let path = CGMutablePath()
        for i in stride(from: 0, to: points.count, by: 2) {
            let pt = CGPoint(x: points[i], y: points[i + 1])
                .downScaledBy(x: scale, y: scale)
                .insetBy(dx: x, dy: y)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        guard !path.isEmpty else { return nil }
        shapeLayer.path = path
        shapeLayer.fillColor = entity.type.color
        shapeLayer.strokeColor = entity.type.borderColor
        shapeLayer.lineWidth = entity.type.borderWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        return shapeLayer
    }

    private func drawCarpet(for entity: VTEntity, boundedByX x: CGFloat, y: CGFloat, scale: CGFloat) -> VTEntityShapeLayer? {
        let shapeLayer = VTEntityShapeLayer(data: entity)
        let points = entity.points

        // extract four corners for carpet
        let pts = stride(from: 0, to: points.count, by: 2).map { i in
            CGPoint(x: points[i], y: points[i + 1])
                .downScaledBy(x: scale, y: scale)
                .insetBy(dx: x, dy: y)
        }

        let lineWidth = entity.type.borderWidth
        let carpetPath = VTPatternFactory.makeCarpetPattern(withPoints: pts, lineWidth: lineWidth)
        guard !carpetPath.isEmpty else { return nil }
        shapeLayer.path = carpetPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = entity.type.borderColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        return shapeLayer
    }

    private func drawObstacle(for entity: VTEntity, boundedByX x: CGFloat, y: CGFloat, scale: CGFloat) -> VTEntityShapeLayer? {
        let shapeLayer = VTEntityShapeLayer(data: entity)

        guard let centerPoint = entity.centerPoint?.downScaledBy(x: scale, y: scale).insetBy(dx: x, dy: y) else {
            return nil
        }

        let path = CGMutablePath()

        let radius: CGFloat = 6.0
        path.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y - radius))
        path.addLine(to: CGPoint(x: centerPoint.x + radius, y: centerPoint.y))
        path.addLine(to: CGPoint(x: centerPoint.x, y: centerPoint.y + radius))
        path.addLine(to: CGPoint(x: centerPoint.x - radius, y: centerPoint.y))
        path.closeSubpath()

        let stemTopWidth: CGFloat = 2.2
        let stemBottomWidth: CGFloat = 1.1
        let stemTopY = centerPoint.y - 2.3
        let stemBottomY = centerPoint.y + 0.9
        path.move(to: CGPoint(x: centerPoint.x - stemTopWidth / 2, y: stemTopY))
        path.addLine(to: CGPoint(x: centerPoint.x + stemTopWidth / 2, y: stemTopY))
        path.addLine(to: CGPoint(x: centerPoint.x + stemBottomWidth / 2, y: stemBottomY))
        path.addLine(to: CGPoint(x: centerPoint.x - stemBottomWidth / 2, y: stemBottomY))
        path.closeSubpath()

        let dotRadius: CGFloat = 0.75
        path.addEllipse(in: CGRect(
            x: centerPoint.x - dotRadius,
            y: centerPoint.y + 2.2,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))

        guard !path.isEmpty else { return nil }
        shapeLayer.path = path
        shapeLayer.fillColor = entity.type.color
        shapeLayer.strokeColor = entity.type.borderColor
        shapeLayer.lineWidth = 0.75
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        return shapeLayer
    }

    private func drawEntities(in container: CALayer, boundedByX x: CGFloat, y: CGFloat) {
        for entity in entities.sorted().reversed() {
            let pixelScale = CGFloat(pixelSize)

            let shapeLayer: VTEntityShapeLayer? = switch entity.type {
            case .charger_location, .robot_position: drawIcon(for: entity, boundedByX: x, y: y, scale: pixelScale)
            case .path: drawPath(for: entity, boundedByX: x, y: y, scale: pixelScale)
            case .carpet: drawCarpet(for: entity, boundedByX: x, y: y, scale: pixelScale)
            case .obstacle: drawObstacle(for: entity, boundedByX: x, y: y, scale: pixelScale)
            default: nil
            }

            guard let shapeLayer else { continue }

            // TODO: Use custom shape layer?
            container.addSublayer(shapeLayer)
        }
    }

    @MainActor
    func toLayer(fitting size: CGSize, screenScale: CGFloat, hideNoGoAreas: Bool) -> CALayer {
        let boundingBox = calculatedBoundingRect()
        let x = boundingBox.minX
        let y = boundingBox.minY
        let width = boundingBox.width
        let height = boundingBox.height
        let scale = min(size.width / width, size.height / height)

        let container = CALayer()
        container.frame = CGRect(x: 0, y: 0, width: width, height: height)
        container.contentsScale = screenScale

        drawRooms(in: container, boundedByX: x, y: y, hideNoGoAreas: hideNoGoAreas)
        drawEntities(in: container, boundedByX: x, y: y)

        container.anchorPoint = .zero
        container.position = .zero
        container.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        return container
    }

    /* func toCGImage(size: CGSize) -> CGImage? {
         let boundingBox = calculatedBoundingRect()
         let x = boundingBox.minX
         let y = boundingBox.minY
         let width = boundingBox.width
         let height = boundingBox.height

         // keep aspect ratio
         let scale = min(size.width / width, size.height / height).rounded(.towardZero)
         let scaleX = scale
         let scaleY = scale

         guard let context = CGContext(
             data: nil,
             width: Int(width * scaleX),
             height: Int(height * scaleY),
             bitsPerComponent: 8,
             bytesPerRow: Int(width * scaleX) * 4, // 4 bytes per pixel (RGBA)
             space: CGColorSpaceCreateDeviceRGB(),
             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
         ) else {
             return nil
         }
         context.scaleBy(x: scaleX, y: scaleY)

         for layer in layers {
             switch (layer.type) {
             case .segment:
                 context.setFillColor(layer.color)
                 for pixel in layer.pixelData() {
                     let rect = CGRect(x: pixel.x - x, y: pixel.y - y, width: 1, height: 1)
                     context.fill(rect)
                 }
             case .floor:
                 continue
             case .wall:
                 context.setFillColor(.black)
                 for pixel in layer.pixelData() {
                     let rect = CGRect(x: pixel.x - x, y: pixel.y - y, width: 1, height: 1)
                     context.fill(rect)
                 }
             }
         }

         return context.makeImage()
     } */
}
