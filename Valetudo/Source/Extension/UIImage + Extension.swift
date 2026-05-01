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

    static let rectangle3GroupFill = UIImage(systemName: "rectangle.3.group.fill")
    static let nosign = UIImage(systemName: "nosign")
    static let pencil = UIImage(systemName: "pencil")
    static let scissors = UIImage(systemName: "scissors")
    static let split = UIImage(systemName: "square.split.bottomrightquarter.fill")
    static let union = UIImage.unionImage()

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
    static let sidebarRight = UIImage(systemName: "sidebar.right")
    static let appLogo = UIImage(named: "Logo")
    static let noMop = UIImage.dropFill?
        .slashed(fillColor: .black, lineWidth: 1.25, cutoutLineWidth: 3.0)
    static let noGo = UIImage(systemName: "wrongwaysign.fill")
    static let wall = UIImage.wallImage()

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
            .foregroundColor: opColor,
        ]
        let lhsSize = lhs?.size ?? .zero
        let rhsSize = rhs?.size ?? .zero
        let opSize = (op as NSString).size(withAttributes: attributes)
        let totalWidth = lhsSize.width + spacing + opSize.width + spacing + rhsSize.width
        let maxHeight = max(lhsSize.height, opFont.lineHeight, rhsSize.height)
        let finalSize = CGSize(width: totalWidth, height: maxHeight)

        let renderer = UIGraphicsImageRenderer(size: finalSize, format: .default())
        return renderer.image { _ in
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

        return image.withRenderingMode(.alwaysOriginal)
    }

    private static func unionImage() -> UIImage {
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size, format: .default())
        let image = renderer.image { context in
            UIColor.black.setFill()

            let leftRect = UIBezierPath(
                roundedRect: CGRect(x: 3, y: 6, width: 11, height: 11),
                cornerRadius: 2.5
            )
            let rightRect = UIBezierPath(
                roundedRect: CGRect(x: 10, y: 8, width: 11, height: 11),
                cornerRadius: 2.5
            )
            leftRect.append(rightRect)
            leftRect.fill()

            // Carve a transparent outline around the shared overlap so the
            // intersection remains legible inside the merged union icon.
            let overlapCutout = UIBezierPath(
                roundedRect: CGRect(x: 10, y: 8, width: 4, height: 9),
                cornerRadius: 1.5
            )
            overlapCutout.lineWidth = 1.25

            context.cgContext.setBlendMode(.clear)
            overlapCutout.stroke()
        }

        return image.withRenderingMode(.alwaysTemplate)
    }

    private static func wallImage() -> UIImage {
        let size = CGSize(width: 20, height: 15)
        let renderer = UIGraphicsImageRenderer(size: size, format: .default())
        let image = renderer.image { _ in
            UIColor.black.setFill()

            let brickSize = CGSize(width: 5, height: 3)
            let cornerRadius: CGFloat = 0.75
            let rows: [[CGFloat]] = [
                [2.5, 8.5, 14.5],
                [5.5, 11.5],
                [2.5, 8.5, 14.5],
            ]
            let rowOriginsY: [CGFloat] = [4.0, 8, 12]

            for (rowIndex, originsX) in rows.enumerated() {
                let originY = rowOriginsY[rowIndex]
                for originX in originsX {
                    let rect = CGRect(
                        x: originX,
                        y: originY,
                        width: brickSize.width,
                        height: brickSize.height
                    )
                    UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).fill()
                }
            }
        }

        return image.withRenderingMode(.alwaysTemplate)
    }
}
