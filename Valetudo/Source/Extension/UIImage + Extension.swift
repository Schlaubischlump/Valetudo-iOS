//
//  UIImage + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import UIKit

public extension UIImage {
    static let addListItem = UIImage(systemName: "plus.circle.fill")
    static let xmark = UIImage(systemName: "xmark")
    static let timerRun = UIImage(systemName: "play.fill")
    static let cleaningStart = UIImage(systemName: "play.fill")
    static let cleaningStop = UIImage(systemName: "stop.fill")
    static let returnToDock = UIImage(systemName: "house.fill")
    static let sidebarMap = UIImage(systemName: "map.fill")
    static let mappingPass = UIImage(systemName: "map.fill")
    static let mapReset = UIImage(systemName: "map.fill")?.slashed(fillColor: .black, lineWidth: 1.25)
    static let segmentManagement = UIImage(systemName: "rectangle.3.group.fill")
    static let virtualRestrictionManagement = UIImage(systemName: "nosign")
    static let material = UIImage(systemName: "rectangle.3.group.fill")
    static let rename = UIImage(systemName: "pencil")
    static let insertCuttingLine = UIImage(systemName: "scissors")
    static let splitSegments = UIImage(systemName: "square.split.bottomrightquarter.fill")
    static let joinSegments = UIImage.unionImage()
    static let sidebarConsumables = UIImage(systemName: "chart.line.text.clipboard.fill")
    static let sidebarRobot = UIImage(systemName: "robotic.vacuum.fill")
    static let discoveredRobot = UIImage(systemName: "robotic.vacuum.fill")
    static let robotNavigationItem = UIImage(systemName: "robotic.vacuum.fill")
    static let sidebarTimers = UIImage(systemName: "clock.fill")
    static let sidebarLog = UIImage(systemName: "text.page.fill")
    static let sidebarSystemInformation = UIImage(systemName: "info.circle.fill")
    static let sidebarUpdater = UIImage(systemName: "square.and.arrow.down.fill")
    static let sidebarManualControl = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right")
    static let timerDelete = UIImage(systemName: "trash")
    static let virtualRestrictionDelete = UIImage(systemName: "trash")
    static let save = UIImage.saveImage()
    static let wifiSlash = UIImage(systemName: "wifi.slash")
    static let updaterUnknownState = UIImage(systemName: "questionmark.circle.fill")
    static let updaterUpToDateState = UIImage(systemName: "checkmark.circle.fill")
    static let updaterErrorState = UIImage(systemName: "xmark.circle.fill")
    static let updaterDisabledState = UIImage(systemName: "circle.slash.fill")
    static let updaterInstall = UIImage(systemName: "arrow.trianglehead.2.counterclockwise")
    static let copyLogLine = UIImage(systemName: "doc.on.doc")
    static let eventsScreen = UIImage(systemName: "bell.fill")
    static let eventsNavigationItem = UIImage(systemName: "bell.fill")
    static let operationModeControl = UIImage(systemName: "filemenu.and.selection")
    static let operationModeVacuum = UIImage(systemName: "fan.fill")
    static let fanSpeedControl = UIImage(systemName: "fan.fill")
    static let operationModeMop = UIImage(systemName: "drop.fill")
    static let waterGradeControl = UIImage(systemName: "drop.fill")
    static let cleaningIterationsControl = UIImage(systemName: "repeat")
    static let dockControls = UIImage(systemName: "dock.arrow.down.rectangle")
    static let dockMopWash = UIImage(systemName: "water.waves")
    static let dockMopDry = UIImage(systemName: "heat.waves.and.fan")
    static let dockEmpty = UIImage(systemName: "arrow.up.trash.fill")
    static let attachments = UIImage(systemName: "puzzlepiece.extension.fill")
    static let currentStatistics = UIImage(systemName: "chart.bar.fill")
    static let inspectorToggle = UIImage(systemName: "sidebar.right")
    static let appLogo = UIImage(named: "Logo")
    static let noMop = UIImage.waterGradeControl?.slashed(fillColor: .black, lineWidth: 1.25)
    static let noGo = UIImage(systemName: "wrongwaysign.fill")
    static let wall = UIImage.wallImage()
    static let locateRobot = UIImage(systemName: "location.fill.viewfinder")
    static let keyLock = UIImage(systemName: "lock.fill")
    static let collisionAvoidantNavigation = UIImage(systemName: "arrow.triangle.branch")
    static let materialAlignedNavigation = UIImage(systemName: "safari.fill")
    static let cleanRoute = UIImage(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
    static let carpetMode = UIImage(systemName: "rectangle.pattern.checkered")
    static let carpetSensor = UIImage(systemName: "sensor.tag.radiowaves.forward")
    static let mopTwist = UIImage(systemName: "arrow.triangle.2.circlepath")
    static let mopExtension = UIImage(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
    static let mopExtensionFurnitureLegHandling = UIImage(systemName: "table.furniture")
    static let obstacleAvoidance = UIImage(systemName: "exclamationmark.triangle.fill")
    static let petObstacleAvoidance = UIImage(systemName: "pawprint.fill")
    static let obstacleImages = UIImage(systemName: "photo.trianglebadge.exclamationmark")
    static let cameraLight = UIImage(systemName: "flashlight.on.fill")
    static let dockAutoEmpty = UIImage(systemName: "dock.arrow.down.rectangle")
    static let autoEmptyDuration = UIImage(systemName: "square.and.arrow.down.badge.clock.fill")
    static let mopAutoDrying = UIImage(systemName: "heat.waves")
    static let mopDryingTime = UIImage(systemName: "timer")
    static let mopWashTemperature = UIImage(systemName: "thermometer.high")
    static let systemOptions = UIImage(systemName: "gearshape.2.fill")
    static let quirks = UIImage(systemName: "star")
    static let speakerQuite = UIImage(systemName: "speaker.fill")
    static let speakerLoud = UIImage(systemName: "speaker.wave.3.fill")
    static let zoneAdd = UIImage(systemName: "plus.rectangle.on.rectangle")
    static let zoneRemove = UIImage(systemName: "trash.fill")

    static let overlayResize = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
    static let overlayRemove = UIImage(systemName: "trash.fill")

    static let operationModeVacuumAndMop = UIImage.combine(left: .operationModeMop, right: .operationModeVacuum)
    static let operationModeVacuumThenMop = UIImage.combine(left: .operationModeVacuum, right: .operationModeMop, op: "→")

    /// Creates a 1x1 image filled with the supplied color.
    /// - Parameter color: The solid fill color to render into the image.
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

    /// Renders a multiplication-style repeat count badge.
    /// - Parameter iterations: The number of repeated passes represented by the badge.
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
        let format = UIGraphicsImageRendererFormat.default()
        let baseScale = max(scale, imageRendererFormat.scale, traitCollection.displayScale)
        if isSymbolImage {
            // This method rasterizes vector symbols into a bitmap. Oversample small
            // symbols so they remain sharp when later displayed at larger sizes.
            let largestDimension = max(size.width, size.height)
            let minimumRasterDimension: CGFloat = 96
            let oversampledScale = largestDimension > 0 ? (minimumRasterDimension / largestDimension) : baseScale
            format.scale = min(8, max(baseScale, oversampledScale))
        } else {
            format.scale = baseScale
        }
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
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

    /// Draws a custom union icon.
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

    /// Draws a brick-wall glyph.
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

    /// Draws a floppy-disk style save icon.
    private static func saveImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size, format: .default())
        let image = renderer.image { context in
            UIColor.black.setFill()

            let body = UIBezierPath()
            body.move(to: CGPoint(x: 3.0, y: 2.0))
            body.addLine(to: CGPoint(x: 16.5, y: 2.0))
            body.addLine(to: CGPoint(x: 19.5, y: 5.0))
            body.addLine(to: CGPoint(x: 19.5, y: 19.0))
            body.addQuadCurve(to: CGPoint(x: 17.0, y: 21.0), controlPoint: CGPoint(x: 19.5, y: 20.0))
            body.addLine(to: CGPoint(x: 5.0, y: 21.0))
            body.addQuadCurve(to: CGPoint(x: 2.5, y: 18.5), controlPoint: CGPoint(x: 2.5, y: 20.0))
            body.addLine(to: CGPoint(x: 2.5, y: 4.5))
            body.addQuadCurve(to: CGPoint(x: 3.0, y: 2.0), controlPoint: CGPoint(x: 2.5, y: 2.0))
            body.close()
            body.fill()

            context.cgContext.setBlendMode(.clear)
            UIBezierPath(roundedRect: CGRect(x: 5.0, y: 4.0, width: 8.5, height: 4.0), cornerRadius: 0.8).fill()
            UIBezierPath(roundedRect: CGRect(x: 7.0, y: 11.0, width: 6.0, height: 6.0), cornerRadius: 3.0).fill()
        }

        return image.withRenderingMode(.alwaysTemplate)
    }
}
