import CoreGraphics
import UIKit

extension UIImage {
    static func fanSpeedLow(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawFanspeedlowicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawFanspeedlowicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 12.31, y: 0.25))
        path.addCurve(to: CGPoint(x: 6.91, y: 7.04),
                      control1: CGPoint(x: 9.58, y: 2.24),
                      control2: CGPoint(x: 7.72, y: 4.49))
        path.addCurve(to: CGPoint(x: 6.99, y: 8.03),
                      control1: CGPoint(x: 6.8, y: 7.36),
                      control2: CGPoint(x: 6.83, y: 7.72))
        path.addCurve(to: CGPoint(x: 7.76, y: 8.68),
                      control1: CGPoint(x: 7.15, y: 8.34),
                      control2: CGPoint(x: 7.43, y: 8.57))
        path.addCurve(to: CGPoint(x: 9.39, y: 7.83),
                      control1: CGPoint(x: 8.44, y: 8.89),
                      control2: CGPoint(x: 9.18, y: 8.52))
        path.addCurve(to: CGPoint(x: 13.84, y: 2.36),
                      control1: CGPoint(x: 9.99, y: 5.96),
                      control2: CGPoint(x: 11.42, y: 4.13))
        path.addCurve(to: CGPoint(x: 14.13, y: 0.54),
                      control1: CGPoint(x: 14.42, y: 1.93),
                      control2: CGPoint(x: 14.55, y: 1.12))
        path.addCurve(to: CGPoint(x: 13.28, y: 0.02),
                      control1: CGPoint(x: 13.92, y: 0.26),
                      control2: CGPoint(x: 13.62, y: 0.07))
        path.addCurve(to: CGPoint(x: 12.31, y: 0.25),
                      control1: CGPoint(x: 12.93, y: -0.04),
                      control2: CGPoint(x: 12.58, y: 0.05))
        path.closeSubpath()
        path.move(to: CGPoint(x: 16.97, y: 6.91))
        path.addCurve(to: CGPoint(x: 15.97, y: 6.99),
                      control1: CGPoint(x: 16.64, y: 6.8),
                      control2: CGPoint(x: 16.28, y: 6.83))
        path.addCurve(to: CGPoint(x: 15.32, y: 7.76),
                      control1: CGPoint(x: 15.66, y: 7.15),
                      control2: CGPoint(x: 15.43, y: 7.43))
        path.addCurve(to: CGPoint(x: 15.41, y: 8.75),
                      control1: CGPoint(x: 15.22, y: 8.09),
                      control2: CGPoint(x: 15.25, y: 8.44))
        path.addCurve(to: CGPoint(x: 16.17, y: 9.4),
                      control1: CGPoint(x: 15.57, y: 9.06),
                      control2: CGPoint(x: 15.84, y: 9.29))
        path.addCurve(to: CGPoint(x: 21.64, y: 13.84),
                      control1: CGPoint(x: 18.04, y: 10),
                      control2: CGPoint(x: 19.88, y: 11.42))
        path.addCurve(to: CGPoint(x: 23.46, y: 14.13),
                      control1: CGPoint(x: 22.07, y: 14.42),
                      control2: CGPoint(x: 22.88, y: 14.55))
        path.addCurve(to: CGPoint(x: 23.98, y: 13.28),
                      control1: CGPoint(x: 23.74, y: 13.92),
                      control2: CGPoint(x: 23.93, y: 13.62))
        path.addCurve(to: CGPoint(x: 23.75, y: 12.3),
                      control1: CGPoint(x: 24.04, y: 12.93),
                      control2: CGPoint(x: 23.95, y: 12.58))
        path.addCurve(to: CGPoint(x: 16.97, y: 6.91),
                      control1: CGPoint(x: 21.76, y: 9.58),
                      control2: CGPoint(x: 19.51, y: 7.72))
        path.closeSubpath()
        path.move(to: CGPoint(x: 1.51, y: 9.64))
        path.addCurve(to: CGPoint(x: 0.54, y: 9.87),
                      control1: CGPoint(x: 1.16, y: 9.58),
                      control2: CGPoint(x: 0.82, y: 9.67))
        path.addCurve(to: CGPoint(x: 0.25, y: 11.7),
                      control1: CGPoint(x: -0.05, y: 10.3),
                      control2: CGPoint(x: -0.17, y: 11.11))
        path.addCurve(to: CGPoint(x: 7.04, y: 17.09),
                      control1: CGPoint(x: 2.24, y: 14.42),
                      control2: CGPoint(x: 4.49, y: 16.28))
        path.addCurve(to: CGPoint(x: 8.67, y: 16.24),
                      control1: CGPoint(x: 7.72, y: 17.31),
                      control2: CGPoint(x: 8.46, y: 16.93))
        path.addCurve(to: CGPoint(x: 7.83, y: 14.61),
                      control1: CGPoint(x: 8.89, y: 15.56),
                      control2: CGPoint(x: 8.51, y: 14.82))
        path.addCurve(to: CGPoint(x: 2.36, y: 10.16),
                      control1: CGPoint(x: 5.95, y: 14.01),
                      control2: CGPoint(x: 4.12, y: 12.58))
        path.addCurve(to: CGPoint(x: 1.51, y: 9.64),
                      control1: CGPoint(x: 2.15, y: 9.88),
                      control2: CGPoint(x: 1.85, y: 9.69))
        path.closeSubpath()
        path.move(to: CGPoint(x: 16.24, y: 15.33))
        path.addCurve(to: CGPoint(x: 15.25, y: 15.41),
                      control1: CGPoint(x: 15.91, y: 15.22),
                      control2: CGPoint(x: 15.56, y: 15.25))
        path.addCurve(to: CGPoint(x: 14.6, y: 16.17),
                      control1: CGPoint(x: 14.94, y: 15.57),
                      control2: CGPoint(x: 14.71, y: 15.84))
        path.addCurve(to: CGPoint(x: 10.16, y: 21.64),
                      control1: CGPoint(x: 14.01, y: 18.04),
                      control2: CGPoint(x: 12.58, y: 19.88))
        path.addCurve(to: CGPoint(x: 9.87, y: 23.46),
                      control1: CGPoint(x: 9.58, y: 22.07),
                      control2: CGPoint(x: 9.45, y: 22.88))
        path.addCurve(to: CGPoint(x: 11.7, y: 23.75),
                      control1: CGPoint(x: 10.3, y: 24.05),
                      control2: CGPoint(x: 11.11, y: 24.17))
        path.addCurve(to: CGPoint(x: 17.09, y: 16.96),
                      control1: CGPoint(x: 14.42, y: 21.76),
                      control2: CGPoint(x: 16.28, y: 19.51))
        path.addCurve(to: CGPoint(x: 16.24, y: 15.33),
                      control1: CGPoint(x: 17.31, y: 16.28),
                      control2: CGPoint(x: 16.93, y: 15.55))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
