import CoreGraphics
import UIKit

extension UIImage {
    static func waterGradeOff(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawWatergradeofficon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawWatergradeofficon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 6.96, y: 8.16))
        path.addCurve(to: CGPoint(x: 7.87, y: 12),
                      control1: CGPoint(x: 7.57, y: 9.31),
                      control2: CGPoint(x: 7.87, y: 10.59))
        path.addCurve(to: CGPoint(x: 6.96, y: 15.84),
                      control1: CGPoint(x: 7.87, y: 13.41),
                      control2: CGPoint(x: 7.57, y: 14.69))
        path.addCurve(to: CGPoint(x: 5.65, y: 17.45),
                      control1: CGPoint(x: 6.6, y: 16.55),
                      control2: CGPoint(x: 6.16, y: 17.08))
        path.addCurve(to: CGPoint(x: 3.93, y: 18),
                      control1: CGPoint(x: 5.14, y: 17.82),
                      control2: CGPoint(x: 4.56, y: 18))
        path.addCurve(to: CGPoint(x: 2.21, y: 17.45),
                      control1: CGPoint(x: 3.3, y: 18),
                      control2: CGPoint(x: 2.73, y: 17.82))
        path.addCurve(to: CGPoint(x: 0.9, y: 15.84),
                      control1: CGPoint(x: 1.7, y: 17.08),
                      control2: CGPoint(x: 1.26, y: 16.55))
        path.addCurve(to: CGPoint(x: -0, y: 12),
                      control1: CGPoint(x: 0.3, y: 14.69),
                      control2: CGPoint(x: -0, y: 13.41))
        path.addCurve(to: CGPoint(x: 0.9, y: 8.16),
                      control1: CGPoint(x: -0, y: 10.59),
                      control2: CGPoint(x: 0.3, y: 9.31))
        path.addCurve(to: CGPoint(x: 2.21, y: 6.56),
                      control1: CGPoint(x: 1.26, y: 7.45),
                      control2: CGPoint(x: 1.7, y: 6.92))
        path.addCurve(to: CGPoint(x: 3.93, y: 6),
                      control1: CGPoint(x: 2.73, y: 6.19),
                      control2: CGPoint(x: 3.3, y: 6))
        path.addCurve(to: CGPoint(x: 5.12, y: 6.25),
                      control1: CGPoint(x: 4.35, y: 6),
                      control2: CGPoint(x: 4.75, y: 6.08))
        path.addCurve(to: CGPoint(x: 6.14, y: 6.99),
                      control1: CGPoint(x: 5.5, y: 6.42),
                      control2: CGPoint(x: 5.84, y: 6.66))
        path.addCurve(to: CGPoint(x: 6.96, y: 8.16),
                      control1: CGPoint(x: 6.45, y: 7.3),
                      control2: CGPoint(x: 6.72, y: 7.69))
        path.closeSubpath()
        path.move(to: CGPoint(x: 5.84, y: 13.7))
        path.addCurve(to: CGPoint(x: 6.05, y: 12),
                      control1: CGPoint(x: 5.98, y: 13.17),
                      control2: CGPoint(x: 6.05, y: 12.61))
        path.addCurve(to: CGPoint(x: 5.84, y: 10.3),
                      control1: CGPoint(x: 6.05, y: 11.39),
                      control2: CGPoint(x: 5.98, y: 10.83))
        path.addCurve(to: CGPoint(x: 5.12, y: 8.73),
                      control1: CGPoint(x: 5.68, y: 9.69),
                      control2: CGPoint(x: 5.44, y: 9.17))
        path.addCurve(to: CGPoint(x: 4.53, y: 8.17),
                      control1: CGPoint(x: 4.92, y: 8.47),
                      control2: CGPoint(x: 4.73, y: 8.28))
        path.addCurve(to: CGPoint(x: 3.93, y: 8),
                      control1: CGPoint(x: 4.34, y: 8.06),
                      control2: CGPoint(x: 4.14, y: 8))
        path.addCurve(to: CGPoint(x: 2.75, y: 8.73),
                      control1: CGPoint(x: 3.51, y: 8),
                      control2: CGPoint(x: 3.12, y: 8.24))
        path.addCurve(to: CGPoint(x: 2.33, y: 9.45),
                      control1: CGPoint(x: 2.59, y: 8.95),
                      control2: CGPoint(x: 2.45, y: 9.19))
        path.addCurve(to: CGPoint(x: 2.02, y: 10.3),
                      control1: CGPoint(x: 2.2, y: 9.71),
                      control2: CGPoint(x: 2.1, y: 9.99))
        path.addCurve(to: CGPoint(x: 1.81, y: 12),
                      control1: CGPoint(x: 1.89, y: 10.82),
                      control2: CGPoint(x: 1.82, y: 11.39))
        path.addCurve(to: CGPoint(x: 2.02, y: 13.7),
                      control1: CGPoint(x: 1.81, y: 12.61),
                      control2: CGPoint(x: 1.88, y: 13.17))
        path.addCurve(to: CGPoint(x: 2.75, y: 15.27),
                      control1: CGPoint(x: 2.18, y: 14.31),
                      control2: CGPoint(x: 2.42, y: 14.83))
        path.addCurve(to: CGPoint(x: 3.93, y: 16),
                      control1: CGPoint(x: 3.12, y: 15.76),
                      control2: CGPoint(x: 3.51, y: 16))
        path.addCurve(to: CGPoint(x: 5.12, y: 15.27),
                      control1: CGPoint(x: 4.35, y: 16),
                      control2: CGPoint(x: 4.75, y: 15.76))
        path.addCurve(to: CGPoint(x: 5.84, y: 13.7),
                      control1: CGPoint(x: 5.44, y: 14.83),
                      control2: CGPoint(x: 5.68, y: 14.31))
        path.closeSubpath()
        path.move(to: CGPoint(x: 15.93, y: 12))
        path.addCurve(to: CGPoint(x: 15.68, y: 12.73),
                      control1: CGPoint(x: 15.93, y: 12.31),
                      control2: CGPoint(x: 15.85, y: 12.55))
        path.addCurve(to: CGPoint(x: 15.03, y: 13),
                      control1: CGPoint(x: 15.52, y: 12.91),
                      control2: CGPoint(x: 15.3, y: 13))
        path.addLine(to: CGPoint(x: 10.56, y: 13))
        path.addLine(to: CGPoint(x: 10.56, y: 17))
        path.addCurve(to: CGPoint(x: 10.31, y: 17.73),
                      control1: CGPoint(x: 10.56, y: 17.31),
                      control2: CGPoint(x: 10.48, y: 17.55))
        path.addCurve(to: CGPoint(x: 9.65, y: 18),
                      control1: CGPoint(x: 10.15, y: 17.91),
                      control2: CGPoint(x: 9.93, y: 18))
        path.addCurve(to: CGPoint(x: 9.47, y: 17.98),
                      control1: CGPoint(x: 9.59, y: 18),
                      control2: CGPoint(x: 9.53, y: 17.99))
        path.addCurve(to: CGPoint(x: 9.3, y: 17.94),
                      control1: CGPoint(x: 9.41, y: 17.98),
                      control2: CGPoint(x: 9.36, y: 17.96))
        path.addCurve(to: CGPoint(x: 9.14, y: 17.86),
                      control1: CGPoint(x: 9.24, y: 17.92),
                      control2: CGPoint(x: 9.19, y: 17.89))
        path.addCurve(to: CGPoint(x: 8.99, y: 17.73),
                      control1: CGPoint(x: 9.08, y: 17.82),
                      control2: CGPoint(x: 9.03, y: 17.78))
        path.addCurve(to: CGPoint(x: 8.79, y: 17.4),
                      control1: CGPoint(x: 8.9, y: 17.63),
                      control2: CGPoint(x: 8.83, y: 17.52))
        path.addCurve(to: CGPoint(x: 8.74, y: 17),
                      control1: CGPoint(x: 8.76, y: 17.27),
                      control2: CGPoint(x: 8.74, y: 17.14))
        path.addLine(to: CGPoint(x: 8.74, y: 6.99))
        path.addCurve(to: CGPoint(x: 8.98, y: 6.27),
                      control1: CGPoint(x: 8.74, y: 6.69),
                      control2: CGPoint(x: 8.82, y: 6.45))
        path.addCurve(to: CGPoint(x: 9.63, y: 6),
                      control1: CGPoint(x: 9.14, y: 6.09),
                      control2: CGPoint(x: 9.36, y: 6))
        path.addLine(to: CGPoint(x: 15.03, y: 6))
        path.addCurve(to: CGPoint(x: 15.68, y: 6.27),
                      control1: CGPoint(x: 15.3, y: 6),
                      control2: CGPoint(x: 15.52, y: 6.09))
        path.addCurve(to: CGPoint(x: 15.93, y: 7),
                      control1: CGPoint(x: 15.85, y: 6.45),
                      control2: CGPoint(x: 15.94, y: 6.69))
        path.addCurve(to: CGPoint(x: 15.68, y: 7.73),
                      control1: CGPoint(x: 15.93, y: 7.31),
                      control2: CGPoint(x: 15.85, y: 7.55))
        path.addCurve(to: CGPoint(x: 15.03, y: 8),
                      control1: CGPoint(x: 15.52, y: 7.91),
                      control2: CGPoint(x: 15.3, y: 8.01))
        path.addLine(to: CGPoint(x: 10.56, y: 8))
        path.addLine(to: CGPoint(x: 10.56, y: 11))
        path.addLine(to: CGPoint(x: 15.03, y: 11))
        path.addCurve(to: CGPoint(x: 15.16, y: 11.01),
                      control1: CGPoint(x: 15.07, y: 11),
                      control2: CGPoint(x: 15.12, y: 11))
        path.addCurve(to: CGPoint(x: 15.3, y: 11.04),
                      control1: CGPoint(x: 15.2, y: 11.02),
                      control2: CGPoint(x: 15.25, y: 11.03))
        path.addCurve(to: CGPoint(x: 15.44, y: 11.08),
                      control1: CGPoint(x: 15.35, y: 11.05),
                      control2: CGPoint(x: 15.39, y: 11.06))
        path.addCurve(to: CGPoint(x: 15.56, y: 11.16),
                      control1: CGPoint(x: 15.48, y: 11.1),
                      control2: CGPoint(x: 15.52, y: 11.13))
        path.addCurve(to: CGPoint(x: 15.68, y: 11.27),
                      control1: CGPoint(x: 15.61, y: 11.19),
                      control2: CGPoint(x: 15.65, y: 11.23))
        path.addCurve(to: CGPoint(x: 15.87, y: 11.61),
                      control1: CGPoint(x: 15.77, y: 11.37),
                      control2: CGPoint(x: 15.84, y: 11.48))
        path.addCurve(to: CGPoint(x: 15.93, y: 12),
                      control1: CGPoint(x: 15.91, y: 11.73),
                      control2: CGPoint(x: 15.93, y: 11.86))
        path.closeSubpath()
        path.move(to: CGPoint(x: 24, y: 12))
        path.addCurve(to: CGPoint(x: 23.75, y: 12.73),
                      control1: CGPoint(x: 24, y: 12.31),
                      control2: CGPoint(x: 23.92, y: 12.55))
        path.addCurve(to: CGPoint(x: 23.09, y: 13),
                      control1: CGPoint(x: 23.59, y: 12.91),
                      control2: CGPoint(x: 23.37, y: 13))
        path.addLine(to: CGPoint(x: 18.63, y: 13))
        path.addLine(to: CGPoint(x: 18.63, y: 17))
        path.addCurve(to: CGPoint(x: 18.38, y: 17.73),
                      control1: CGPoint(x: 18.63, y: 17.31),
                      control2: CGPoint(x: 18.55, y: 17.55))
        path.addCurve(to: CGPoint(x: 17.71, y: 18),
                      control1: CGPoint(x: 18.22, y: 17.91),
                      control2: CGPoint(x: 18, y: 18))
        path.addCurve(to: CGPoint(x: 17.54, y: 17.98),
                      control1: CGPoint(x: 17.66, y: 18),
                      control2: CGPoint(x: 17.6, y: 17.99))
        path.addCurve(to: CGPoint(x: 17.36, y: 17.94),
                      control1: CGPoint(x: 17.48, y: 17.98),
                      control2: CGPoint(x: 17.42, y: 17.96))
        path.addCurve(to: CGPoint(x: 17.2, y: 17.86),
                      control1: CGPoint(x: 17.31, y: 17.92),
                      control2: CGPoint(x: 17.26, y: 17.89))
        path.addCurve(to: CGPoint(x: 17.06, y: 17.73),
                      control1: CGPoint(x: 17.15, y: 17.82),
                      control2: CGPoint(x: 17.1, y: 17.78))
        path.addCurve(to: CGPoint(x: 16.86, y: 17.4),
                      control1: CGPoint(x: 16.97, y: 17.63),
                      control2: CGPoint(x: 16.9, y: 17.52))
        path.addCurve(to: CGPoint(x: 16.81, y: 17),
                      control1: CGPoint(x: 16.82, y: 17.27),
                      control2: CGPoint(x: 16.81, y: 17.14))
        path.addLine(to: CGPoint(x: 16.81, y: 6.99))
        path.addCurve(to: CGPoint(x: 17.05, y: 6.27),
                      control1: CGPoint(x: 16.81, y: 6.69),
                      control2: CGPoint(x: 16.89, y: 6.45))
        path.addCurve(to: CGPoint(x: 17.7, y: 6),
                      control1: CGPoint(x: 17.21, y: 6.09),
                      control2: CGPoint(x: 17.43, y: 6))
        path.addLine(to: CGPoint(x: 23.09, y: 6))
        path.addCurve(to: CGPoint(x: 23.75, y: 6.27),
                      control1: CGPoint(x: 23.37, y: 6),
                      control2: CGPoint(x: 23.59, y: 6.09))
        path.addCurve(to: CGPoint(x: 24, y: 7),
                      control1: CGPoint(x: 23.92, y: 6.45),
                      control2: CGPoint(x: 24, y: 6.69))
        path.addCurve(to: CGPoint(x: 23.75, y: 7.73),
                      control1: CGPoint(x: 24, y: 7.31),
                      control2: CGPoint(x: 23.92, y: 7.55))
        path.addCurve(to: CGPoint(x: 23.09, y: 8),
                      control1: CGPoint(x: 23.59, y: 7.91),
                      control2: CGPoint(x: 23.37, y: 8.01))
        path.addLine(to: CGPoint(x: 18.63, y: 8))
        path.addLine(to: CGPoint(x: 18.63, y: 11))
        path.addLine(to: CGPoint(x: 23.09, y: 11))
        path.addCurve(to: CGPoint(x: 23.23, y: 11.01),
                      control1: CGPoint(x: 23.14, y: 11),
                      control2: CGPoint(x: 23.19, y: 11))
        path.addCurve(to: CGPoint(x: 23.37, y: 11.04),
                      control1: CGPoint(x: 23.27, y: 11.02),
                      control2: CGPoint(x: 23.32, y: 11.03))
        path.addCurve(to: CGPoint(x: 23.5, y: 11.08),
                      control1: CGPoint(x: 23.42, y: 11.05),
                      control2: CGPoint(x: 23.46, y: 11.06))
        path.addCurve(to: CGPoint(x: 23.63, y: 11.16),
                      control1: CGPoint(x: 23.55, y: 11.1),
                      control2: CGPoint(x: 23.59, y: 11.13))
        path.addCurve(to: CGPoint(x: 23.75, y: 11.27),
                      control1: CGPoint(x: 23.68, y: 11.19),
                      control2: CGPoint(x: 23.72, y: 11.23))
        path.addCurve(to: CGPoint(x: 23.94, y: 11.61),
                      control1: CGPoint(x: 23.84, y: 11.37),
                      control2: CGPoint(x: 23.9, y: 11.48))
        path.addCurve(to: CGPoint(x: 24, y: 12),
                      control1: CGPoint(x: 23.98, y: 11.73),
                      control2: CGPoint(x: 24, y: 11.86))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
