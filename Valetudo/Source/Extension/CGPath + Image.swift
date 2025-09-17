//
//  CGPath + Image.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit
import CoreGraphics

extension CGPath {

    func rotated(by angle: CGFloat) -> CGPath {
        let origin = self.boundingBox.center
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: origin.x, y: origin.y)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -origin.x, y: -origin.y)
        return self.copy(using: &transform) ?? self
    }
    
    func renderedImage(
            size: CGSize,
            strokeColor: UIColor = .black,
            fillColor: UIColor = .clear,
            lineWidth: CGFloat = 1.0,
            scale: CGFloat
        ) -> UIImage {
            let rendererFormat = UIGraphicsImageRendererFormat.default()
            rendererFormat.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)

            return renderer.image { context in
                let cgContext = context.cgContext

                // Scale path to fit the image
                let bounds = self.boundingBox
                let scaleX = (size.width - lineWidth * 2) / bounds.width
                let scaleY = (size.height - lineWidth * 2) / bounds.height
                let fittingScale = min(scaleX, scaleY)

                // Center and scale path
                cgContext.translateBy(x: size.width / 2, y: size.height / 2)
                cgContext.scaleBy(x: fittingScale, y: fittingScale)
                cgContext.translateBy(x: -bounds.midX, y: -bounds.midY)

                cgContext.setStrokeColor(strokeColor.cgColor)
                cgContext.setFillColor(fillColor.cgColor)
                cgContext.setLineWidth(lineWidth)
                cgContext.addPath(self)
                cgContext.drawPath(using: .fillStroke)
            }
        }
}
