//
//  UIImage + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import UIKit

public extension UIImage {
    static let plusCircleFill = UIImage(systemName: "plus.circle.fill")
    static let xmark = UIImage(systemName: "xmark")
    static let playFill = UIImage(systemName: "play.fill")
    static let stopFill = UIImage(systemName: "stop.fill")
    static let houseFill = UIImage(systemName: "house.fill")
    static let mapFill = UIImage(systemName: "map.fill")
    static let mapSlash: UIImage? = {
        guard let image = UIImage.mapFill else { return nil }
        return image.slashed(fillColor: .black, lineWidth: 1.25)
    }()
    static let chartLineTextClipboardFill = UIImage(systemName: "chart.line.text.clipboard.fill")
    static let roboticVacuumFill = UIImage(systemName: "robotic.vacuum.fill")
    static let clockFill = UIImage(systemName: "clock.fill")
    static let textPageFill = UIImage(systemName: "text.page.fill")
    static let infoCircleFill = UIImage(systemName: "info.circle.fill")
    static let squareAndArrowDownFill = UIImage(systemName: "square.and.arrow.down.fill")
    static let arrowUpAndDownAndArrowLeftAndRight = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right")
    static let trash = UIImage(systemName: "trash")
    static let wifiSlash = UIImage(systemName: "wifi.slash")
    static let questionmarkCircleFill = UIImage(systemName: "questionmark.circle.fill")
    static let checkmarkCircleFill = UIImage(systemName: "checkmark.circle.fill")
    static let xmarkCircleFill = UIImage(systemName: "xmark.circle.fill")
    static let circleSlashFill = UIImage(systemName: "circle.slash.fill")
    static let arrowTrianglehead2Counterclockwise = UIImage(systemName: "arrow.trianglehead.2.counterclockwise")
    static let docOnDoc = UIImage(systemName: "doc.on.doc")
    static let bellFill = UIImage(systemName: "bell.fill")
    static let filemenuAndSelection = UIImage(systemName: "filemenu.and.selection")
    static let fanFill = UIImage(systemName: "fan.fill")
    static let dropFill = UIImage(systemName: "drop.fill")
    static let repeatSymbol = UIImage(systemName: "repeat")
    static let dockArrowDownRectangle = UIImage(systemName: "dock.arrow.down.rectangle")
    static let waterWaves = UIImage(systemName: "water.waves")
    static let heatWavesAndFan = UIImage(systemName: "heat.waves.and.fan")
    static let arrowUpTrashFill = UIImage(systemName: "arrow.up.trash.fill")
    static let puzzlepieceExtensionFill = UIImage(systemName: "puzzlepiece.extension.fill")
    static let chartBarFill = UIImage(systemName: "chart.bar.fill")
    static let appLogo = UIImage(named: "Logo")
    
    static let operationModeVacuumAndMop = UIImage.combine(left: .dropFill, right: .fanFill)
    static let operationModeVacuumThenMop = UIImage.combine(left: .fanFill, right: .dropFill, op: "→")
    
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
    
    static func repeatCount(_ iterations: Int) -> UIImage {
        .textImage("× \(iterations)")
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
