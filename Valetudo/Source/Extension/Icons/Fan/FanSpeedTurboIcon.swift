import CoreGraphics
import UIKit

extension UIImage {
    static func fanSpeedTurbo(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawFanspeedturboicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawFanspeedturboicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 14.54, y: 0))
        path.addCurve(to: CGPoint(x: 13.92, y: 0.15),
                      control1: CGPoint(x: 14.33, y: -0),
                      control2: CGPoint(x: 14.11, y: 0.05))
        path.addCurve(to: CGPoint(x: 7.57, y: 6.31),
                      control1: CGPoint(x: 10.89, y: 1.81),
                      control2: CGPoint(x: 8.72, y: 3.85))
        path.addCurve(to: CGPoint(x: 8.16, y: 7.94),
                      control1: CGPoint(x: 7.28, y: 6.92),
                      control2: CGPoint(x: 7.55, y: 7.65))
        path.addCurve(to: CGPoint(x: 9.79, y: 7.35),
                      control1: CGPoint(x: 8.77, y: 8.23),
                      control2: CGPoint(x: 9.5, y: 7.97))
        path.addCurve(to: CGPoint(x: 15.1, y: 2.31),
                      control1: CGPoint(x: 10.67, y: 5.49),
                      control2: CGPoint(x: 12.38, y: 3.79))
        path.addCurve(to: CGPoint(x: 15.59, y: 0.64),
                      control1: CGPoint(x: 15.7, y: 1.98),
                      control2: CGPoint(x: 15.92, y: 1.23))
        path.addCurve(to: CGPoint(x: 14.86, y: 0.05),
                      control1: CGPoint(x: 15.43, y: 0.35),
                      control2: CGPoint(x: 15.17, y: 0.14))
        path.addCurve(to: CGPoint(x: 14.54, y: 0),
                      control1: CGPoint(x: 14.75, y: 0.02),
                      control2: CGPoint(x: 14.65, y: 0))
        path.closeSubpath()
        path.move(to: CGPoint(x: 6.19, y: 1.38))
        path.addCurve(to: CGPoint(x: 4.98, y: 2.26),
                      control1: CGPoint(x: 5.63, y: 1.37),
                      control2: CGPoint(x: 5.14, y: 1.73))
        path.addCurve(to: CGPoint(x: 4.84, y: 11.11),
                      control1: CGPoint(x: 4.01, y: 5.58),
                      control2: CGPoint(x: 3.92, y: 8.55))
        path.addCurve(to: CGPoint(x: 5.47, y: 11.8),
                      control1: CGPoint(x: 4.95, y: 11.42),
                      control2: CGPoint(x: 5.18, y: 11.67))
        path.addCurve(to: CGPoint(x: 6.41, y: 11.85),
                      control1: CGPoint(x: 5.77, y: 11.94),
                      control2: CGPoint(x: 6.11, y: 11.96))
        path.addCurve(to: CGPoint(x: 7.11, y: 11.21),
                      control1: CGPoint(x: 6.72, y: 11.74),
                      control2: CGPoint(x: 6.97, y: 11.51))
        path.addCurve(to: CGPoint(x: 7.15, y: 10.27),
                      control1: CGPoint(x: 7.25, y: 10.92),
                      control2: CGPoint(x: 7.26, y: 10.58))
        path.addCurve(to: CGPoint(x: 7.34, y: 2.95),
                      control1: CGPoint(x: 6.45, y: 8.34),
                      control2: CGPoint(x: 6.47, y: 5.93))
        path.addCurve(to: CGPoint(x: 7.24, y: 2.02),
                      control1: CGPoint(x: 7.43, y: 2.64),
                      control2: CGPoint(x: 7.4, y: 2.3))
        path.addCurve(to: CGPoint(x: 6.51, y: 1.43),
                      control1: CGPoint(x: 7.08, y: 1.73),
                      control2: CGPoint(x: 6.82, y: 1.52))
        path.addCurve(to: CGPoint(x: 6.19, y: 1.38),
                      control1: CGPoint(x: 6.4, y: 1.4),
                      control2: CGPoint(x: 6.3, y: 1.38))
        path.closeSubpath()
        path.move(to: CGPoint(x: 16.76, y: 4.2))
        path.addCurve(to: CGPoint(x: 12.89, y: 4.84),
                      control1: CGPoint(x: 15.38, y: 4.2),
                      control2: CGPoint(x: 14.09, y: 4.41))
        path.addCurve(to: CGPoint(x: 12.2, y: 5.47),
                      control1: CGPoint(x: 12.58, y: 4.95),
                      control2: CGPoint(x: 12.33, y: 5.18))
        path.addCurve(to: CGPoint(x: 12.15, y: 6.41),
                      control1: CGPoint(x: 12.06, y: 5.77),
                      control2: CGPoint(x: 12.04, y: 6.11))
        path.addCurve(to: CGPoint(x: 12.79, y: 7.11),
                      control1: CGPoint(x: 12.26, y: 6.72),
                      control2: CGPoint(x: 12.49, y: 6.97))
        path.addCurve(to: CGPoint(x: 13.73, y: 7.15),
                      control1: CGPoint(x: 13.08, y: 7.25),
                      control2: CGPoint(x: 13.42, y: 7.26))
        path.addCurve(to: CGPoint(x: 21.05, y: 7.34),
                      control1: CGPoint(x: 15.66, y: 6.45),
                      control2: CGPoint(x: 18.07, y: 6.47))
        path.addCurve(to: CGPoint(x: 21.98, y: 7.24),
                      control1: CGPoint(x: 21.36, y: 7.43),
                      control2: CGPoint(x: 21.7, y: 7.4))
        path.addCurve(to: CGPoint(x: 22.57, y: 6.51),
                      control1: CGPoint(x: 22.27, y: 7.08),
                      control2: CGPoint(x: 22.48, y: 6.82))
        path.addCurve(to: CGPoint(x: 22.47, y: 5.57),
                      control1: CGPoint(x: 22.66, y: 6.19),
                      control2: CGPoint(x: 22.63, y: 5.86))
        path.addCurve(to: CGPoint(x: 21.74, y: 4.98),
                      control1: CGPoint(x: 22.31, y: 5.28),
                      control2: CGPoint(x: 22.05, y: 5.07))
        path.addCurve(to: CGPoint(x: 17.03, y: 4.2),
                      control1: CGPoint(x: 20.08, y: 4.5),
                      control2: CGPoint(x: 18.51, y: 4.23))
        path.addCurve(to: CGPoint(x: 16.76, y: 4.2),
                      control1: CGPoint(x: 16.94, y: 4.2),
                      control2: CGPoint(x: 16.85, y: 4.2))
        path.closeSubpath()
        path.move(to: CGPoint(x: 17.07, y: 7.46))
        path.addCurve(to: CGPoint(x: 16.06, y: 8.16),
                      control1: CGPoint(x: 16.63, y: 7.49),
                      control2: CGPoint(x: 16.25, y: 7.76))
        path.addCurve(to: CGPoint(x: 16.65, y: 9.79),
                      control1: CGPoint(x: 15.77, y: 8.77),
                      control2: CGPoint(x: 16.03, y: 9.5))
        path.addCurve(to: CGPoint(x: 21.69, y: 15.1),
                      control1: CGPoint(x: 18.51, y: 10.67),
                      control2: CGPoint(x: 20.2, y: 12.38))
        path.addCurve(to: CGPoint(x: 23.36, y: 15.59),
                      control1: CGPoint(x: 22.02, y: 15.7),
                      control2: CGPoint(x: 22.77, y: 15.92))
        path.addCurve(to: CGPoint(x: 23.85, y: 13.92),
                      control1: CGPoint(x: 23.96, y: 15.27),
                      control2: CGPoint(x: 24.17, y: 14.52))
        path.addCurve(to: CGPoint(x: 17.69, y: 7.57),
                      control1: CGPoint(x: 22.19, y: 10.89),
                      control2: CGPoint(x: 20.15, y: 8.72))
        path.addCurve(to: CGPoint(x: 17.07, y: 7.46),
                      control1: CGPoint(x: 17.5, y: 7.48),
                      control2: CGPoint(x: 17.28, y: 7.44))
        path.closeSubpath()
        path.move(to: CGPoint(x: 1.26, y: 8.26))
        path.addCurve(to: CGPoint(x: 0.64, y: 8.41),
                      control1: CGPoint(x: 1.04, y: 8.25),
                      control2: CGPoint(x: 0.83, y: 8.3))
        path.addCurve(to: CGPoint(x: 0.15, y: 10.08),
                      control1: CGPoint(x: 0.04, y: 8.73),
                      control2: CGPoint(x: -0.17, y: 9.48))
        path.addCurve(to: CGPoint(x: 6.31, y: 16.43),
                      control1: CGPoint(x: 1.81, y: 13.11),
                      control2: CGPoint(x: 3.85, y: 15.28))
        path.addCurve(to: CGPoint(x: 7.94, y: 15.84),
                      control1: CGPoint(x: 6.92, y: 16.72),
                      control2: CGPoint(x: 7.65, y: 16.45))
        path.addCurve(to: CGPoint(x: 7.35, y: 14.21),
                      control1: CGPoint(x: 8.23, y: 15.23),
                      control2: CGPoint(x: 7.97, y: 14.5))
        path.addCurve(to: CGPoint(x: 2.31, y: 8.9),
                      control1: CGPoint(x: 5.49, y: 13.33),
                      control2: CGPoint(x: 3.8, y: 11.62))
        path.addCurve(to: CGPoint(x: 1.57, y: 8.31),
                      control1: CGPoint(x: 2.15, y: 8.61),
                      control2: CGPoint(x: 1.89, y: 8.4))
        path.addCurve(to: CGPoint(x: 1.26, y: 8.26),
                      control1: CGPoint(x: 1.47, y: 8.28),
                      control2: CGPoint(x: 1.37, y: 8.26))
        path.closeSubpath()
        path.move(to: CGPoint(x: 17.9, y: 12.08))
        path.addCurve(to: CGPoint(x: 17.59, y: 12.15),
                      control1: CGPoint(x: 17.79, y: 12.09),
                      control2: CGPoint(x: 17.69, y: 12.12))
        path.addCurve(to: CGPoint(x: 16.89, y: 12.79),
                      control1: CGPoint(x: 17.28, y: 12.26),
                      control2: CGPoint(x: 17.03, y: 12.49))
        path.addCurve(to: CGPoint(x: 16.85, y: 13.73),
                      control1: CGPoint(x: 16.75, y: 13.08),
                      control2: CGPoint(x: 16.74, y: 13.42))
        path.addCurve(to: CGPoint(x: 16.66, y: 21.05),
                      control1: CGPoint(x: 17.55, y: 15.66),
                      control2: CGPoint(x: 17.53, y: 18.07))
        path.addCurve(to: CGPoint(x: 16.76, y: 21.98),
                      control1: CGPoint(x: 16.57, y: 21.36),
                      control2: CGPoint(x: 16.6, y: 21.7))
        path.addCurve(to: CGPoint(x: 17.49, y: 22.57),
                      control1: CGPoint(x: 16.92, y: 22.27),
                      control2: CGPoint(x: 17.18, y: 22.48))
        path.addCurve(to: CGPoint(x: 18.43, y: 22.47),
                      control1: CGPoint(x: 17.81, y: 22.66),
                      control2: CGPoint(x: 18.14, y: 22.63))
        path.addCurve(to: CGPoint(x: 19.02, y: 21.74),
                      control1: CGPoint(x: 18.72, y: 22.31),
                      control2: CGPoint(x: 18.93, y: 22.05))
        path.addCurve(to: CGPoint(x: 19.16, y: 12.89),
                      control1: CGPoint(x: 19.99, y: 18.42),
                      control2: CGPoint(x: 20.08, y: 15.45))
        path.addCurve(to: CGPoint(x: 17.9, y: 12.08),
                      control1: CGPoint(x: 18.97, y: 12.37),
                      control2: CGPoint(x: 18.45, y: 12.04))
        path.closeSubpath()
        path.move(to: CGPoint(x: 15.21, y: 15.95))
        path.addCurve(to: CGPoint(x: 14.21, y: 16.65),
                      control1: CGPoint(x: 14.78, y: 15.98),
                      control2: CGPoint(x: 14.39, y: 16.25))
        path.addCurve(to: CGPoint(x: 8.9, y: 21.69),
                      control1: CGPoint(x: 13.33, y: 18.51),
                      control2: CGPoint(x: 11.62, y: 20.21))
        path.addCurve(to: CGPoint(x: 8.41, y: 23.36),
                      control1: CGPoint(x: 8.3, y: 22.02),
                      control2: CGPoint(x: 8.08, y: 22.77))
        path.addCurve(to: CGPoint(x: 10.08, y: 23.85),
                      control1: CGPoint(x: 8.73, y: 23.96),
                      control2: CGPoint(x: 9.48, y: 24.18))
        path.addCurve(to: CGPoint(x: 16.43, y: 17.69),
                      control1: CGPoint(x: 13.11, y: 22.19),
                      control2: CGPoint(x: 15.28, y: 20.15))
        path.addCurve(to: CGPoint(x: 15.84, y: 16.06),
                      control1: CGPoint(x: 16.72, y: 17.08),
                      control2: CGPoint(x: 16.45, y: 16.35))
        path.addCurve(to: CGPoint(x: 15.21, y: 15.95),
                      control1: CGPoint(x: 15.65, y: 15.97),
                      control2: CGPoint(x: 15.43, y: 15.93))
        path.closeSubpath()
        path.move(to: CGPoint(x: 2.64, y: 16.61))
        path.addCurve(to: CGPoint(x: 1.43, y: 17.49),
                      control1: CGPoint(x: 2.08, y: 16.6),
                      control2: CGPoint(x: 1.58, y: 16.96))
        path.addCurve(to: CGPoint(x: 1.53, y: 18.43),
                      control1: CGPoint(x: 1.34, y: 17.81),
                      control2: CGPoint(x: 1.37, y: 18.14))
        path.addCurve(to: CGPoint(x: 2.26, y: 19.02),
                      control1: CGPoint(x: 1.69, y: 18.72),
                      control2: CGPoint(x: 1.95, y: 18.93))
        path.addCurve(to: CGPoint(x: 11.11, y: 19.16),
                      control1: CGPoint(x: 5.58, y: 19.99),
                      control2: CGPoint(x: 8.55, y: 20.08))
        path.addCurve(to: CGPoint(x: 11.8, y: 18.53),
                      control1: CGPoint(x: 11.42, y: 19.05),
                      control2: CGPoint(x: 11.67, y: 18.82))
        path.addCurve(to: CGPoint(x: 11.85, y: 17.59),
                      control1: CGPoint(x: 11.94, y: 18.23),
                      control2: CGPoint(x: 11.96, y: 17.89))
        path.addCurve(to: CGPoint(x: 11.21, y: 16.89),
                      control1: CGPoint(x: 11.74, y: 17.28),
                      control2: CGPoint(x: 11.51, y: 17.03))
        path.addCurve(to: CGPoint(x: 10.27, y: 16.85),
                      control1: CGPoint(x: 10.92, y: 16.75),
                      control2: CGPoint(x: 10.58, y: 16.74))
        path.addCurve(to: CGPoint(x: 2.95, y: 16.66),
                      control1: CGPoint(x: 8.34, y: 17.55),
                      control2: CGPoint(x: 5.93, y: 17.53))
        path.addCurve(to: CGPoint(x: 2.64, y: 16.61),
                      control1: CGPoint(x: 2.85, y: 16.63),
                      control2: CGPoint(x: 2.74, y: 16.61))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
