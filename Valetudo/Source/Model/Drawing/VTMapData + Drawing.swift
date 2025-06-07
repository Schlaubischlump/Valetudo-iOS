//
//  VTMapData + Drawing.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import Foundation
import CoreGraphics
import QuartzCore


extension VTMapData {
    private func calculatedBoundingRect() -> CGRect {
        var minPoint: CGPoint = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
        var maxPoint: CGPoint = CGPoint(x: -CGFloat.infinity, y: -CGFloat.infinity)
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

    func toLayer(fitting size: CGSize, screenScale: CGFloat) -> CALayer {
        let boundingBox = calculatedBoundingRect()
        let x = boundingBox.minX
        let y = boundingBox.minY
        let width = boundingBox.width
        let height = boundingBox.height
        let scale = min(size.width / width, size.height / height)

        let container = CALayer()
        container.frame = CGRect(x: 0, y: 0, width: width, height: height)
        container.contentsScale = screenScale

        // Draw layers
        for layer in layers {
            let path = CGMutablePath()

            for pixel in layer.pixelData() {
                let rect = CGRect(origin: pixel.insetBy(dx: x, dy: y), size: .one)
                path.addRect(rect)
            }

            guard !path.isEmpty else { continue }

            let shapeLayer = VTLayerShapeLayer(data: layer)
            shapeLayer.path = path
            shapeLayer.strokeColor = nil
            shapeLayer.fillColor = switch layer.type {
                case .segment:  layer.color
                case .wall:     CGColor.black
                case .floor:    nil
            }
            container.addSublayer(shapeLayer)
        }
        
        // Draw entities
        for entity in entities.sorted().reversed() {
            let shapeLayer = VTEntityShapeLayer(data: entity)
            
            let pixelScale = CGFloat(pixelSize)
            
            switch (entity.type) {
            case .charger_location, .robot_position:
                guard let centerPoint = entity.centerPoint?.downScaledBy(x: pixelScale, y: pixelScale) else {
                    fatalError("Expected a unique center point for entity: \(entity)")
                }
                
                guard let icon = entity.type.icon(center: centerPoint.insetBy(dx: x, dy: y)) else {
                    continue
                }
                let angleInRadians = entity.angleInDegree * (.pi / 180)
                shapeLayer.path = icon.rotated(by: angleInRadians)
                shapeLayer.fillColor = entity.type.color
                shapeLayer.strokeColor = entity.type.borderColor
                shapeLayer.lineWidth = entity.type.borderWidth
            case .path:
                let path = CGMutablePath()
                let points = entity.points
                for i in stride(from: 0, to: points.count, by: 2) {
                    let pt = CGPoint(x: points[i], y: points[i+1])
                        .downScaledBy(x: pixelScale, y: pixelScale)
                        .insetBy(dx: x, dy: y)
                    if i == 0 {
                        path.move(to: pt)
                    } else {
                        path.addLine(to: pt)
                    }
                }
                guard !path.isEmpty else { continue }
                shapeLayer.path = path
                shapeLayer.fillColor = entity.type.color
                shapeLayer.strokeColor = entity.type.borderColor
                shapeLayer.lineWidth = entity.type.borderWidth
                shapeLayer.lineCap = .round
                shapeLayer.lineJoin = .round
            default:
                break
            }
            
            // TODO: Use custom shape layer?
            container.addSublayer(shapeLayer)
        }

        container.anchorPoint = .zero
        container.position = .zero
        container.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        return container
    }


    /*func toCGImage(size: CGSize) -> CGImage? {
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
    }*/
}
