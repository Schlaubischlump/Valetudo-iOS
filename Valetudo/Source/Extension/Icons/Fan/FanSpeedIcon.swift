import CoreGraphics
import UIKit

extension UIImage {
    static func fanSpeed(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawFanspeedicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawFanspeedicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 12, y: 11))
        path.addCurve(to: CGPoint(x: 11.29, y: 11.29),
                      control1: CGPoint(x: 11.73, y: 11),
                      control2: CGPoint(x: 11.48, y: 11.11))
        path.addCurve(to: CGPoint(x: 11, y: 12),
                      control1: CGPoint(x: 11.11, y: 11.48),
                      control2: CGPoint(x: 11, y: 11.73))
        path.addCurve(to: CGPoint(x: 11.29, y: 12.71),
                      control1: CGPoint(x: 11, y: 12.27),
                      control2: CGPoint(x: 11.11, y: 12.52))
        path.addCurve(to: CGPoint(x: 12, y: 13),
                      control1: CGPoint(x: 11.48, y: 12.89),
                      control2: CGPoint(x: 11.73, y: 13))
        path.addCurve(to: CGPoint(x: 12.71, y: 12.71),
                      control1: CGPoint(x: 12.27, y: 13),
                      control2: CGPoint(x: 12.52, y: 12.89))
        path.addCurve(to: CGPoint(x: 13, y: 12),
                      control1: CGPoint(x: 12.89, y: 12.52),
                      control2: CGPoint(x: 13, y: 12.27))
        path.addCurve(to: CGPoint(x: 12.71, y: 11.29),
                      control1: CGPoint(x: 13, y: 11.73),
                      control2: CGPoint(x: 12.89, y: 11.48))
        path.addCurve(to: CGPoint(x: 12, y: 11),
                      control1: CGPoint(x: 12.52, y: 11.11),
                      control2: CGPoint(x: 12.27, y: 11))
        path.move(to: CGPoint(x: 12.5, y: 2))
        path.addCurve(to: CGPoint(x: 14.75, y: 6.75),
                      control1: CGPoint(x: 17, y: 2),
                      control2: CGPoint(x: 17.11, y: 5.57))
        path.addCurve(to: CGPoint(x: 13.13, y: 9.22),
                      control1: CGPoint(x: 13.76, y: 7.24),
                      control2: CGPoint(x: 13.32, y: 8.29))
        path.addCurve(to: CGPoint(x: 14.35, y: 10.13),
                      control1: CGPoint(x: 13.61, y: 9.42),
                      control2: CGPoint(x: 14.03, y: 9.73))
        path.addCurve(to: CGPoint(x: 22.03, y: 12.5),
                      control1: CGPoint(x: 18.05, y: 8.13),
                      control2: CGPoint(x: 22.03, y: 8.92))
        path.addCurve(to: CGPoint(x: 17.28, y: 14.73),
                      control1: CGPoint(x: 22.03, y: 17),
                      control2: CGPoint(x: 18.46, y: 17.1))
        path.addCurve(to: CGPoint(x: 14.79, y: 13.11),
                      control1: CGPoint(x: 16.78, y: 13.74),
                      control2: CGPoint(x: 15.72, y: 13.3))
        path.addCurve(to: CGPoint(x: 13.88, y: 14.34),
                      control1: CGPoint(x: 14.59, y: 13.59),
                      control2: CGPoint(x: 14.28, y: 14))
        path.addCurve(to: CGPoint(x: 11.5, y: 22),
                      control1: CGPoint(x: 15.87, y: 18.03),
                      control2: CGPoint(x: 15.08, y: 22))
        path.addCurve(to: CGPoint(x: 9.27, y: 17.24),
                      control1: CGPoint(x: 7, y: 22),
                      control2: CGPoint(x: 6.91, y: 18.42))
        path.addCurve(to: CGPoint(x: 10.89, y: 14.79),
                      control1: CGPoint(x: 10.25, y: 16.75),
                      control2: CGPoint(x: 10.69, y: 15.71))
        path.addCurve(to: CGPoint(x: 9.65, y: 13.87),
                      control1: CGPoint(x: 10.4, y: 14.59),
                      control2: CGPoint(x: 9.97, y: 14.27))
        path.addCurve(to: CGPoint(x: 2, y: 11.5),
                      control1: CGPoint(x: 5.96, y: 15.85),
                      control2: CGPoint(x: 2, y: 15.07))
        path.addCurve(to: CGPoint(x: 6.74, y: 9.26),
                      control1: CGPoint(x: 2, y: 7),
                      control2: CGPoint(x: 5.56, y: 6.89))
        path.addCurve(to: CGPoint(x: 9.22, y: 10.87),
                      control1: CGPoint(x: 7.24, y: 10.25),
                      control2: CGPoint(x: 8.29, y: 10.68))
        path.addCurve(to: CGPoint(x: 10.14, y: 9.65),
                      control1: CGPoint(x: 9.41, y: 10.39),
                      control2: CGPoint(x: 9.73, y: 9.97))
        path.addCurve(to: CGPoint(x: 12.5, y: 2),
                      control1: CGPoint(x: 8.15, y: 5.96),
                      control2: CGPoint(x: 8.94, y: 2))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
