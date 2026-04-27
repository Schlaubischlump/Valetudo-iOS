import CoreGraphics
import UIKit

extension UIImage {
    static func fanSpeedMin(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawFanspeedminicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawFanspeedminicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 12.6, y: 1))
        path.addCurve(to: CGPoint(x: 11.6, y: 1.32),
                      control1: CGPoint(x: 12.24, y: 0.97),
                      control2: CGPoint(x: 11.88, y: 1.08))
        path.addCurve(to: CGPoint(x: 6.07, y: 9.44),
                      control1: CGPoint(x: 8.68, y: 3.8),
                      control2: CGPoint(x: 6.77, y: 6.5))
        path.addCurve(to: CGPoint(x: 7.07, y: 11.08),
                      control1: CGPoint(x: 5.89, y: 10.17),
                      control2: CGPoint(x: 6.34, y: 10.91))
        path.addCurve(to: CGPoint(x: 8.11, y: 10.92),
                      control1: CGPoint(x: 7.43, y: 11.17),
                      control2: CGPoint(x: 7.8, y: 11.11))
        path.addCurve(to: CGPoint(x: 8.72, y: 10.08),
                      control1: CGPoint(x: 8.41, y: 10.73),
                      control2: CGPoint(x: 8.64, y: 10.43))
        path.addCurve(to: CGPoint(x: 13.37, y: 3.4),
                      control1: CGPoint(x: 9.25, y: 7.86),
                      control2: CGPoint(x: 10.74, y: 5.63))
        path.addCurve(to: CGPoint(x: 13.53, y: 1.48),
                      control1: CGPoint(x: 13.94, y: 2.91),
                      control2: CGPoint(x: 14.01, y: 2.05))
        path.addCurve(to: CGPoint(x: 12.6, y: 1),
                      control1: CGPoint(x: 13.29, y: 1.2),
                      control2: CGPoint(x: 12.96, y: 1.03))
        path.closeSubpath()
        path.move(to: CGPoint(x: 18.74, y: 11.59))
        path.addCurve(to: CGPoint(x: 17.78, y: 12.01),
                      control1: CGPoint(x: 18.38, y: 11.6),
                      control2: CGPoint(x: 18.03, y: 11.75))
        path.addCurve(to: CGPoint(x: 17.83, y: 13.94),
                      control1: CGPoint(x: 17.27, y: 12.56),
                      control2: CGPoint(x: 17.29, y: 13.42))
        path.addCurve(to: CGPoint(x: 21.29, y: 21.31),
                      control1: CGPoint(x: 19.49, y: 15.51),
                      control2: CGPoint(x: 20.68, y: 17.92))
        path.addCurve(to: CGPoint(x: 22.88, y: 22.41),
                      control1: CGPoint(x: 21.43, y: 22.05),
                      control2: CGPoint(x: 22.14, y: 22.54))
        path.addCurve(to: CGPoint(x: 23.76, y: 21.84),
                      control1: CGPoint(x: 23.23, y: 22.34),
                      control2: CGPoint(x: 23.55, y: 22.14))
        path.addCurve(to: CGPoint(x: 23.98, y: 20.82),
                      control1: CGPoint(x: 23.96, y: 21.54),
                      control2: CGPoint(x: 24.04, y: 21.17))
        path.addCurve(to: CGPoint(x: 19.71, y: 11.96),
                      control1: CGPoint(x: 23.29, y: 17.04),
                      control2: CGPoint(x: 21.9, y: 14.04))
        path.addCurve(to: CGPoint(x: 18.74, y: 11.59),
                      control1: CGPoint(x: 19.45, y: 11.71),
                      control2: CGPoint(x: 19.1, y: 11.58))
        path.closeSubpath()
        path.move(to: CGPoint(x: 1.48, y: 19.14))
        path.addCurve(to: CGPoint(x: 0.08, y: 20.04),
                      control1: CGPoint(x: 0.86, y: 19.09),
                      control2: CGPoint(x: 0.29, y: 19.46))
        path.addCurve(to: CGPoint(x: 0.13, y: 21.08),
                      control1: CGPoint(x: -0.04, y: 20.38),
                      control2: CGPoint(x: -0.02, y: 20.76))
        path.addCurve(to: CGPoint(x: 0.9, y: 21.79),
                      control1: CGPoint(x: 0.28, y: 21.41),
                      control2: CGPoint(x: 0.56, y: 21.66))
        path.addCurve(to: CGPoint(x: 10.7, y: 22.52),
                      control1: CGPoint(x: 4.52, y: 23.08),
                      control2: CGPoint(x: 7.81, y: 23.38))
        path.addCurve(to: CGPoint(x: 11.63, y: 20.83),
                      control1: CGPoint(x: 11.43, y: 22.31),
                      control2: CGPoint(x: 11.84, y: 21.55))
        path.addCurve(to: CGPoint(x: 10.97, y: 20.01),
                      control1: CGPoint(x: 11.52, y: 20.48),
                      control2: CGPoint(x: 11.29, y: 20.19))
        path.addCurve(to: CGPoint(x: 9.93, y: 19.9),
                      control1: CGPoint(x: 10.65, y: 19.84),
                      control2: CGPoint(x: 10.28, y: 19.8))
        path.addCurve(to: CGPoint(x: 1.82, y: 19.22),
                      control1: CGPoint(x: 7.74, y: 20.55),
                      control2: CGPoint(x: 5.07, y: 20.38))
        path.addCurve(to: CGPoint(x: 1.48, y: 19.14),
                      control1: CGPoint(x: 1.71, y: 19.18),
                      control2: CGPoint(x: 1.6, y: 19.15))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
