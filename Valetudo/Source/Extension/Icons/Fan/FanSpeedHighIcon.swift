import CoreGraphics
import UIKit

extension UIImage {
    static func fanSpeedHigh(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawFanspeedhighicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawFanspeedhighicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 11.82, y: 0))
        path.addCurve(to: CGPoint(x: 10.96, y: 0.32),
                      control1: CGPoint(x: 11.5, y: -0.01),
                      control2: CGPoint(x: 11.19, y: 0.1))
        path.addCurve(to: CGPoint(x: 6.43, y: 7.69),
                      control1: CGPoint(x: 8.49, y: 2.62),
                      control2: CGPoint(x: 6.93, y: 5.08))
        path.addCurve(to: CGPoint(x: 7.38, y: 9.09),
                      control1: CGPoint(x: 6.31, y: 8.34),
                      control2: CGPoint(x: 6.73, y: 8.96))
        path.addCurve(to: CGPoint(x: 8.79, y: 8.13),
                      control1: CGPoint(x: 8.03, y: 9.21),
                      control2: CGPoint(x: 8.66, y: 8.79))
        path.addCurve(to: CGPoint(x: 12.59, y: 2.08),
                      control1: CGPoint(x: 9.16, y: 6.16),
                      control2: CGPoint(x: 10.38, y: 4.14))
        path.addCurve(to: CGPoint(x: 12.65, y: 0.38),
                      control1: CGPoint(x: 13.08, y: 1.63),
                      control2: CGPoint(x: 13.1, y: 0.87))
        path.addCurve(to: CGPoint(x: 11.82, y: 0),
                      control1: CGPoint(x: 12.43, y: 0.15),
                      control2: CGPoint(x: 12.13, y: 0.01))
        path.closeSubpath()
        path.move(to: CGPoint(x: 16.46, y: 4.43))
        path.addCurve(to: CGPoint(x: 12.95, y: 5.02),
                      control1: CGPoint(x: 15.22, y: 4.45),
                      control2: CGPoint(x: 14.05, y: 4.64))
        path.addCurve(to: CGPoint(x: 12.21, y: 6.55),
                      control1: CGPoint(x: 12.33, y: 5.24),
                      control2: CGPoint(x: 12, y: 5.92))
        path.addCurve(to: CGPoint(x: 12.82, y: 7.23),
                      control1: CGPoint(x: 12.32, y: 6.85),
                      control2: CGPoint(x: 12.54, y: 7.09))
        path.addCurve(to: CGPoint(x: 13.74, y: 7.28),
                      control1: CGPoint(x: 13.11, y: 7.37),
                      control2: CGPoint(x: 13.44, y: 7.39))
        path.addCurve(to: CGPoint(x: 20.89, y: 7.55),
                      control1: CGPoint(x: 15.64, y: 6.62),
                      control2: CGPoint(x: 17.99, y: 6.67))
        path.addCurve(to: CGPoint(x: 21.8, y: 7.46),
                      control1: CGPoint(x: 21.19, y: 7.65),
                      control2: CGPoint(x: 21.52, y: 7.61))
        path.addCurve(to: CGPoint(x: 22.39, y: 6.76),
                      control1: CGPoint(x: 22.09, y: 7.32),
                      control2: CGPoint(x: 22.3, y: 7.06))
        path.addCurve(to: CGPoint(x: 21.59, y: 5.26),
                      control1: CGPoint(x: 22.58, y: 6.12),
                      control2: CGPoint(x: 22.23, y: 5.45))
        path.addCurve(to: CGPoint(x: 17, y: 4.44),
                      control1: CGPoint(x: 19.98, y: 4.76),
                      control2: CGPoint(x: 18.45, y: 4.49))
        path.addCurve(to: CGPoint(x: 16.46, y: 4.43),
                      control1: CGPoint(x: 16.82, y: 4.43),
                      control2: CGPoint(x: 16.64, y: 4.43))
        path.closeSubpath()
        path.move(to: CGPoint(x: 2.58, y: 5.6))
        path.addCurve(to: CGPoint(x: 2.26, y: 5.62),
                      control1: CGPoint(x: 2.47, y: 5.59),
                      control2: CGPoint(x: 2.37, y: 5.6))
        path.addCurve(to: CGPoint(x: 1.52, y: 6.16),
                      control1: CGPoint(x: 1.95, y: 5.7),
                      control2: CGPoint(x: 1.68, y: 5.89))
        path.addCurve(to: CGPoint(x: 1.36, y: 7.06),
                      control1: CGPoint(x: 1.35, y: 6.43),
                      control2: CGPoint(x: 1.29, y: 6.75))
        path.addCurve(to: CGPoint(x: 5.48, y: 14.67),
                      control1: CGPoint(x: 2.12, y: 10.35),
                      control2: CGPoint(x: 3.47, y: 12.93))
        path.addCurve(to: CGPoint(x: 7.17, y: 14.54),
                      control1: CGPoint(x: 5.98, y: 15.1),
                      control2: CGPoint(x: 6.74, y: 15.04))
        path.addCurve(to: CGPoint(x: 7.05, y: 12.85),
                      control1: CGPoint(x: 7.6, y: 14.04),
                      control2: CGPoint(x: 7.55, y: 13.28))
        path.addCurve(to: CGPoint(x: 3.7, y: 6.52),
                      control1: CGPoint(x: 5.53, y: 11.54),
                      control2: CGPoint(x: 4.39, y: 9.48))
        path.addCurve(to: CGPoint(x: 2.58, y: 5.6),
                      control1: CGPoint(x: 3.58, y: 6),
                      control2: CGPoint(x: 3.12, y: 5.61))
        path.closeSubpath()
        path.move(to: CGPoint(x: 17.65, y: 9.05))
        path.addCurve(to: CGPoint(x: 16.83, y: 9.46),
                      control1: CGPoint(x: 17.33, y: 9.07),
                      control2: CGPoint(x: 17.04, y: 9.22))
        path.addCurve(to: CGPoint(x: 16.95, y: 11.15),
                      control1: CGPoint(x: 16.4, y: 9.96),
                      control2: CGPoint(x: 16.45, y: 10.72))
        path.addCurve(to: CGPoint(x: 20.3, y: 17.48),
                      control1: CGPoint(x: 18.47, y: 12.46),
                      control2: CGPoint(x: 19.61, y: 14.52))
        path.addCurve(to: CGPoint(x: 20.83, y: 18.22),
                      control1: CGPoint(x: 20.37, y: 17.79),
                      control2: CGPoint(x: 20.56, y: 18.05))
        path.addCurve(to: CGPoint(x: 21.74, y: 18.38),
                      control1: CGPoint(x: 21.1, y: 18.39),
                      control2: CGPoint(x: 21.42, y: 18.45))
        path.addCurve(to: CGPoint(x: 22.48, y: 17.84),
                      control1: CGPoint(x: 22.05, y: 18.3),
                      control2: CGPoint(x: 22.31, y: 18.11))
        path.addCurve(to: CGPoint(x: 22.64, y: 16.94),
                      control1: CGPoint(x: 22.65, y: 17.57),
                      control2: CGPoint(x: 22.71, y: 17.25))
        path.addCurve(to: CGPoint(x: 18.52, y: 9.33),
                      control1: CGPoint(x: 21.88, y: 13.65),
                      control2: CGPoint(x: 20.53, y: 11.07))
        path.addCurve(to: CGPoint(x: 17.65, y: 9.05),
                      control1: CGPoint(x: 18.28, y: 9.13),
                      control2: CGPoint(x: 17.97, y: 9.02))
        path.closeSubpath()
        path.move(to: CGPoint(x: 16.3, y: 14.89))
        path.addCurve(to: CGPoint(x: 15.21, y: 15.87),
                      control1: CGPoint(x: 15.76, y: 14.93),
                      control2: CGPoint(x: 15.31, y: 15.33))
        path.addCurve(to: CGPoint(x: 11.41, y: 21.92),
                      control1: CGPoint(x: 14.84, y: 17.84),
                      control2: CGPoint(x: 13.62, y: 19.86))
        path.addCurve(to: CGPoint(x: 11.35, y: 23.62),
                      control1: CGPoint(x: 10.92, y: 22.37),
                      control2: CGPoint(x: 10.9, y: 23.13))
        path.addCurve(to: CGPoint(x: 13.04, y: 23.68),
                      control1: CGPoint(x: 11.8, y: 24.1),
                      control2: CGPoint(x: 12.56, y: 24.13))
        path.addCurve(to: CGPoint(x: 17.57, y: 16.31),
                      control1: CGPoint(x: 15.51, y: 21.38),
                      control2: CGPoint(x: 17.07, y: 18.92))
        path.addCurve(to: CGPoint(x: 16.62, y: 14.91),
                      control1: CGPoint(x: 17.69, y: 15.66),
                      control2: CGPoint(x: 17.27, y: 15.04))
        path.addCurve(to: CGPoint(x: 16.3, y: 14.89),
                      control1: CGPoint(x: 16.51, y: 14.89),
                      control2: CGPoint(x: 16.41, y: 14.89))
        path.closeSubpath()
        path.move(to: CGPoint(x: 2.8, y: 16.39))
        path.addCurve(to: CGPoint(x: 1.61, y: 17.24),
                      control1: CGPoint(x: 2.26, y: 16.38),
                      control2: CGPoint(x: 1.77, y: 16.72))
        path.addCurve(to: CGPoint(x: 2.41, y: 18.74),
                      control1: CGPoint(x: 1.42, y: 17.88),
                      control2: CGPoint(x: 1.77, y: 18.55))
        path.addCurve(to: CGPoint(x: 11.05, y: 18.98),
                      control1: CGPoint(x: 5.63, y: 19.73),
                      control2: CGPoint(x: 8.54, y: 19.85))
        path.addCurve(to: CGPoint(x: 11.79, y: 17.45),
                      control1: CGPoint(x: 11.67, y: 18.76),
                      control2: CGPoint(x: 12, y: 18.08))
        path.addCurve(to: CGPoint(x: 11.18, y: 16.77),
                      control1: CGPoint(x: 11.68, y: 17.15),
                      control2: CGPoint(x: 11.46, y: 16.91))
        path.addCurve(to: CGPoint(x: 10.26, y: 16.72),
                      control1: CGPoint(x: 10.89, y: 16.63),
                      control2: CGPoint(x: 10.56, y: 16.61))
        path.addCurve(to: CGPoint(x: 3.11, y: 16.45),
                      control1: CGPoint(x: 8.36, y: 17.38),
                      control2: CGPoint(x: 6.01, y: 17.33))
        path.addCurve(to: CGPoint(x: 2.8, y: 16.39),
                      control1: CGPoint(x: 3.01, y: 16.42),
                      control2: CGPoint(x: 2.91, y: 16.4))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
