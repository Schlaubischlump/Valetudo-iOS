import CoreGraphics
import UIKit

extension UIImage {
    static func fanSpeedMedium(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawFanspeedmediumicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawFanspeedmediumicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 13.18, y: 0))
        path.addCurve(to: CGPoint(x: 12.55, y: 0.2),
                      control1: CGPoint(x: 12.96, y: 0.01),
                      control2: CGPoint(x: 12.74, y: 0.08))
        path.addCurve(to: CGPoint(x: 6.46, y: 7.01),
                      control1: CGPoint(x: 9.55, y: 2.13),
                      control2: CGPoint(x: 7.47, y: 4.39))
        path.addCurve(to: CGPoint(x: 6.48, y: 7.99),
                      control1: CGPoint(x: 6.34, y: 7.33),
                      control2: CGPoint(x: 6.35, y: 7.68))
        path.addCurve(to: CGPoint(x: 7.19, y: 8.65),
                      control1: CGPoint(x: 6.62, y: 8.29),
                      control2: CGPoint(x: 6.88, y: 8.53))
        path.addCurve(to: CGPoint(x: 8.83, y: 7.92),
                      control1: CGPoint(x: 7.84, y: 8.9),
                      control2: CGPoint(x: 8.58, y: 8.58))
        path.addCurve(to: CGPoint(x: 13.93, y: 2.34),
                      control1: CGPoint(x: 9.59, y: 5.94),
                      control2: CGPoint(x: 11.23, y: 4.07))
        path.addCurve(to: CGPoint(x: 14.31, y: 0.58),
                      control1: CGPoint(x: 14.51, y: 1.96),
                      control2: CGPoint(x: 14.68, y: 1.17))
        path.addCurve(to: CGPoint(x: 13.18, y: 0),
                      control1: CGPoint(x: 14.06, y: 0.2),
                      control2: CGPoint(x: 13.63, y: -0.02))
        path.closeSubpath()
        path.move(to: CGPoint(x: 1.28, y: 6.09))
        path.addCurve(to: CGPoint(x: 0.95, y: 6.13),
                      control1: CGPoint(x: 1.17, y: 6.09),
                      control2: CGPoint(x: 1.06, y: 6.1))
        path.addCurve(to: CGPoint(x: 0.17, y: 6.72),
                      control1: CGPoint(x: 0.62, y: 6.22),
                      control2: CGPoint(x: 0.34, y: 6.43))
        path.addCurve(to: CGPoint(x: 0.04, y: 7.68),
                      control1: CGPoint(x: 0, y: 7.01),
                      control2: CGPoint(x: -0.04, y: 7.36))
        path.addCurve(to: CGPoint(x: 4.64, y: 15.58),
                      control1: CGPoint(x: 0.95, y: 11.13),
                      control2: CGPoint(x: 2.46, y: 13.81))
        path.addCurve(to: CGPoint(x: 5.57, y: 15.86),
                      control1: CGPoint(x: 4.9, y: 15.79),
                      control2: CGPoint(x: 5.24, y: 15.89))
        path.addCurve(to: CGPoint(x: 6.43, y: 15.39),
                      control1: CGPoint(x: 5.91, y: 15.82),
                      control2: CGPoint(x: 6.21, y: 15.66))
        path.addCurve(to: CGPoint(x: 6.7, y: 14.46),
                      control1: CGPoint(x: 6.64, y: 15.13),
                      control2: CGPoint(x: 6.74, y: 14.8))
        path.addCurve(to: CGPoint(x: 6.24, y: 13.61),
                      control1: CGPoint(x: 6.67, y: 14.13),
                      control2: CGPoint(x: 6.5, y: 13.82))
        path.addCurve(to: CGPoint(x: 2.5, y: 7.04),
                      control1: CGPoint(x: 4.59, y: 12.27),
                      control2: CGPoint(x: 3.32, y: 10.13))
        path.addCurve(to: CGPoint(x: 1.28, y: 6.09),
                      control1: CGPoint(x: 2.35, y: 6.48),
                      control2: CGPoint(x: 1.85, y: 6.09))
        path.closeSubpath()
        path.move(to: CGPoint(x: 15.17, y: 6.1))
        path.addCurve(to: CGPoint(x: 14.26, y: 6.42),
                      control1: CGPoint(x: 14.83, y: 6.08),
                      control2: CGPoint(x: 14.51, y: 6.19))
        path.addCurve(to: CGPoint(x: 13.84, y: 7.3),
                      control1: CGPoint(x: 14.01, y: 6.65),
                      control2: CGPoint(x: 13.85, y: 6.96))
        path.addCurve(to: CGPoint(x: 14.16, y: 8.21),
                      control1: CGPoint(x: 13.82, y: 7.63),
                      control2: CGPoint(x: 13.94, y: 7.96))
        path.addCurve(to: CGPoint(x: 15.04, y: 8.63),
                      control1: CGPoint(x: 14.39, y: 8.46),
                      control2: CGPoint(x: 14.7, y: 8.61))
        path.addCurve(to: CGPoint(x: 21.93, y: 11.75),
                      control1: CGPoint(x: 17.16, y: 8.74),
                      control2: CGPoint(x: 19.45, y: 9.73))
        path.addCurve(to: CGPoint(x: 22.86, y: 12.03),
                      control1: CGPoint(x: 22.19, y: 11.97),
                      control2: CGPoint(x: 22.52, y: 12.07))
        path.addCurve(to: CGPoint(x: 23.71, y: 11.57),
                      control1: CGPoint(x: 23.19, y: 12),
                      control2: CGPoint(x: 23.5, y: 11.83))
        path.addCurve(to: CGPoint(x: 23.53, y: 9.79),
                      control1: CGPoint(x: 24.16, y: 11.03),
                      control2: CGPoint(x: 24.08, y: 10.23))
        path.addCurve(to: CGPoint(x: 15.17, y: 6.1),
                      control1: CGPoint(x: 20.77, y: 7.53),
                      control2: CGPoint(x: 17.98, y: 6.24))
        path.closeSubpath()
        path.move(to: CGPoint(x: 17.51, y: 13.16))
        path.addCurve(to: CGPoint(x: 17.18, y: 13.2),
                      control1: CGPoint(x: 17.4, y: 13.16),
                      control2: CGPoint(x: 17.29, y: 13.17))
        path.addCurve(to: CGPoint(x: 16.28, y: 14.75),
                      control1: CGPoint(x: 16.5, y: 13.38),
                      control2: CGPoint(x: 16.1, y: 14.08))
        path.addCurve(to: CGPoint(x: 15.44, y: 22.27),
                      control1: CGPoint(x: 16.83, y: 16.8),
                      control2: CGPoint(x: 16.6, y: 19.29))
        path.addCurve(to: CGPoint(x: 15.47, y: 23.24),
                      control1: CGPoint(x: 15.32, y: 22.59),
                      control2: CGPoint(x: 15.33, y: 22.93))
        path.addCurve(to: CGPoint(x: 16.17, y: 23.91),
                      control1: CGPoint(x: 15.6, y: 23.55),
                      control2: CGPoint(x: 15.86, y: 23.79))
        path.addCurve(to: CGPoint(x: 17.14, y: 23.89),
                      control1: CGPoint(x: 16.48, y: 24.04),
                      control2: CGPoint(x: 16.83, y: 24.03))
        path.addCurve(to: CGPoint(x: 17.81, y: 23.19),
                      control1: CGPoint(x: 17.45, y: 23.76),
                      control2: CGPoint(x: 17.69, y: 23.5))
        path.addCurve(to: CGPoint(x: 18.74, y: 14.1),
                      control1: CGPoint(x: 19.1, y: 19.86),
                      control2: CGPoint(x: 19.46, y: 16.81))
        path.addCurve(to: CGPoint(x: 17.51, y: 13.16),
                      control1: CGPoint(x: 18.59, y: 13.54),
                      control2: CGPoint(x: 18.08, y: 13.16))
        path.closeSubpath()
        path.move(to: CGPoint(x: 11.47, y: 17.63))
        path.addCurve(to: CGPoint(x: 10.85, y: 17.83),
                      control1: CGPoint(x: 11.25, y: 17.64),
                      control2: CGPoint(x: 11.03, y: 17.71))
        path.addCurve(to: CGPoint(x: 3.44, y: 19.36),
                      control1: CGPoint(x: 9.07, y: 18.99),
                      control2: CGPoint(x: 6.64, y: 19.54))
        path.addCurve(to: CGPoint(x: 2.52, y: 19.68),
                      control1: CGPoint(x: 3.1, y: 19.34),
                      control2: CGPoint(x: 2.77, y: 19.45))
        path.addCurve(to: CGPoint(x: 2.1, y: 20.55),
                      control1: CGPoint(x: 2.27, y: 19.9),
                      control2: CGPoint(x: 2.12, y: 20.22))
        path.addCurve(to: CGPoint(x: 2.42, y: 21.47),
                      control1: CGPoint(x: 2.08, y: 20.89),
                      control2: CGPoint(x: 2.2, y: 21.22))
        path.addCurve(to: CGPoint(x: 3.3, y: 21.89),
                      control1: CGPoint(x: 2.64, y: 21.72),
                      control2: CGPoint(x: 2.96, y: 21.87))
        path.addCurve(to: CGPoint(x: 12.23, y: 19.96),
                      control1: CGPoint(x: 6.86, y: 22.09),
                      control2: CGPoint(x: 9.87, y: 21.49))
        path.addCurve(to: CGPoint(x: 12.78, y: 19.16),
                      control1: CGPoint(x: 12.51, y: 19.78),
                      control2: CGPoint(x: 12.71, y: 19.49))
        path.addCurve(to: CGPoint(x: 12.6, y: 18.21),
                      control1: CGPoint(x: 12.85, y: 18.83),
                      control2: CGPoint(x: 12.78, y: 18.49))
        path.addCurve(to: CGPoint(x: 11.47, y: 17.63),
                      control1: CGPoint(x: 12.35, y: 17.83),
                      control2: CGPoint(x: 11.92, y: 17.61))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
