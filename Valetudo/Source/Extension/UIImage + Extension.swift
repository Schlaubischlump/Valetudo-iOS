//
//  UIImage + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import UIKit

public extension UIImage {
    static let mapReset: UIImage? = {
        guard let image = UIImage(systemName: "map.fill") else { return nil }
        return image.slashed(fillColor: .black, lineWidth: 1.25)
    }()
    
    convenience init?(color: UIColor) {
        let rect = CGRect(origin: .zero, size: .one)
        UIGraphicsBeginImageContextWithOptions(.one, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    /// Creates an image by rendering a text glyph into a new image context.
    /// - Parameter text: The text to render.
    /// - Parameter font: The font used to render `text`.
    /// - Parameter color: The color used to render `text`.
    static func textImage(
        _ text: String,
        font: UIFont = .boldSystemFont(ofSize: 24),
        color: UIColor = .black
    ) -> UIImage {
        .combine(op: text, opFont: font, opColor: color, spacing: 0)
    }
    
    /// Combines two images with an optional text operator rendered between them.
    /// - Parameter lhs: The image drawn on the left side.
    /// - Parameter rhs: The image drawn on the right side.
    /// - Parameter op: The text operator drawn between the two images.
    /// - Parameter opFont: The font used to render `op`.
    /// - Parameter opColor: The color used to render `op`.
    /// - Parameter spacing: The horizontal spacing inserted around `op`.
    static func combine(
        left lhs: UIImage? = nil,
        right rhs: UIImage? = nil,
        op: String = "➕",
        opFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        opColor: UIColor = .black,
        spacing: CGFloat = 0
    ) -> UIImage {
        // Attributes for plus string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: opFont,
            .foregroundColor: opColor
        ]
        let lhsSize = lhs?.size ?? .zero
        let rhsSize = rhs?.size ?? .zero
        let opSize = (op as NSString).size(withAttributes: attributes)
        let totalWidth = lhsSize.width + spacing + opSize.width + spacing + rhsSize.width
        let maxHeight = max(lhsSize.height, opFont.lineHeight, rhsSize.height)
        let finalSize = CGSize(width: totalWidth, height: maxHeight)

        let renderer = UIGraphicsImageRenderer(size: finalSize, format: .default())
        return renderer.image { ctx in
            let lhsOrigin = CGPoint(x: 0, y: (maxHeight - lhsSize.height) / 2)
            lhs?.draw(in: CGRect(origin: lhsOrigin, size: lhsSize))

            let opX = lhsSize.width + spacing
            let opY = (maxHeight - opFont.lineHeight) / 2
            let opRect = CGRect(x: opX, y: opY, width: opSize.width, height: opFont.lineHeight)
            (op as NSString).draw(in: opRect, withAttributes: attributes)

            let rhsX = opX + opSize.width + spacing
            let rhsOrigin = CGPoint(x: rhsX, y: (maxHeight - rhsSize.height) / 2)
            rhs?.draw(in: CGRect(origin: rhsOrigin, size: rhsSize))
        }
    }

    /// Returns a copy of the image with a diagonal slash made from a wider clear cutout
    /// and a narrower visible inner stroke.
    /// - Parameter fillColor: The color used to tint the base image and the visible slash stroke.
    /// - Parameter lineWidth: The width of the visible inner slash stroke.
    /// - Parameter cutoutLineWidth: The width of the transparent slash cutout. Defaults to a multiple of `lineWidth`.
    /// - Parameter lineOffset: The inset used for the slash start and end points.
    func slashed(
        fillColor: UIColor = .black,
        lineWidth: CGFloat = 0.5,
        cutoutLineWidth: CGFloat? = nil,
        lineOffset: CGFloat = 2.0
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size, format: .default())
        let image = renderer.image { context in
            withTintColor(fillColor, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(origin: .zero, size: size))
            
            let slashPath = UIBezierPath()
            slashPath.move(to: CGPoint(x: size.width - lineOffset, y: size.height - lineOffset))
            slashPath.addLine(to: CGPoint(x: lineOffset, y: lineOffset))
            slashPath.lineCapStyle = .round

            // First clear a wider diagonal so the slash gets a transparent border.
            context.cgContext.setBlendMode(.clear)
            slashPath.lineWidth = cutoutLineWidth ?? (lineWidth * 2.5)
            slashPath.stroke()
            context.cgContext.setBlendMode(.normal)

            // Then draw the visible inner slash on top of the cleared path.
            fillColor.setStroke()
            slashPath.lineWidth = lineWidth
            slashPath.stroke()
        }

        return image.withRenderingMode(.alwaysTemplate)
    }
}
