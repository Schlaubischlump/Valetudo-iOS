import CoreGraphics
import UIKit

extension UIImage {
  static func svgRobotmonochromeicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawRobotmonochromeicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawRobotmonochromeicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 11.28, y: 24))
    path.addCurve(to: CGPoint(x: 10.89, y: 23.96),
                   control1: CGPoint(x: 11.23, y: 23.99),
                   control2: CGPoint(x: 11.06, y: 23.97))
    path.addCurve(to: CGPoint(x: 8.22, y: 23.4),
                   control1: CGPoint(x: 10.05, y: 23.89),
                   control2: CGPoint(x: 9.07, y: 23.68))
    path.addCurve(to: CGPoint(x: 5.3, y: 21.96),
                   control1: CGPoint(x: 7.23, y: 23.07),
                   control2: CGPoint(x: 6.17, y: 22.55))
    path.addCurve(to: CGPoint(x: 2.38, y: 19.18),
                   control1: CGPoint(x: 4.2, y: 21.23),
                   control2: CGPoint(x: 3.16, y: 20.24))
    path.addCurve(to: CGPoint(x: 1.88, y: 5.55),
                   control1: CGPoint(x: -0.6, y: 15.17),
                   control2: CGPoint(x: -0.8, y: 9.77))
    path.addCurve(to: CGPoint(x: 3.16, y: 3.88),
                   control1: CGPoint(x: 2.24, y: 4.99),
                   control2: CGPoint(x: 2.75, y: 4.32))
    path.addCurve(to: CGPoint(x: 3.42, y: 3.61),
                   control1: CGPoint(x: 3.25, y: 3.79),
                   control2: CGPoint(x: 3.37, y: 3.66))
    path.addCurve(to: CGPoint(x: 3.84, y: 3.2),
                   control1: CGPoint(x: 3.47, y: 3.55),
                   control2: CGPoint(x: 3.66, y: 3.37))
    path.addCurve(to: CGPoint(x: 8.29, y: 0.59),
                   control1: CGPoint(x: 5.18, y: 1.98),
                   control2: CGPoint(x: 6.6, y: 1.14))
    path.addCurve(to: CGPoint(x: 14.33, y: 0.23),
                   control1: CGPoint(x: 10.22, y: -0.04),
                   control2: CGPoint(x: 12.33, y: -0.17))
    path.addCurve(to: CGPoint(x: 19.75, y: 2.83),
                   control1: CGPoint(x: 16.34, y: 0.63),
                   control2: CGPoint(x: 18.15, y: 1.49))
    path.addCurve(to: CGPoint(x: 21.16, y: 4.23),
                   control1: CGPoint(x: 20.12, y: 3.14),
                   control2: CGPoint(x: 20.84, y: 3.85))
    path.addCurve(to: CGPoint(x: 22.71, y: 6.58),
                   control1: CGPoint(x: 21.79, y: 4.98),
                   control2: CGPoint(x: 22.27, y: 5.7))
    path.addCurve(to: CGPoint(x: 23.95, y: 10.77),
                   control1: CGPoint(x: 23.39, y: 7.91),
                   control2: CGPoint(x: 23.78, y: 9.23))
    path.addCurve(to: CGPoint(x: 23.94, y: 13.36),
                   control1: CGPoint(x: 24.02, y: 11.35),
                   control2: CGPoint(x: 24.01, y: 12.76))
    path.addCurve(to: CGPoint(x: 20.05, y: 20.92),
                   control1: CGPoint(x: 23.58, y: 16.33),
                   control2: CGPoint(x: 22.24, y: 18.94))
    path.addCurve(to: CGPoint(x: 14.92, y: 23.65),
                   control1: CGPoint(x: 18.61, y: 22.23),
                   control2: CGPoint(x: 16.82, y: 23.18))
    path.addCurve(to: CGPoint(x: 12.15, y: 24),
                   control1: CGPoint(x: 13.92, y: 23.9),
                   control2: CGPoint(x: 13.24, y: 23.99))
    path.addCurve(to: CGPoint(x: 11.28, y: 24),
                   control1: CGPoint(x: 11.71, y: 24),
                   control2: CGPoint(x: 11.32, y: 24))
    path.closeSubpath()
    path.move(to: CGPoint(x: 13.08, y: 21.46))
    path.addCurve(to: CGPoint(x: 17.95, y: 19.43),
                   control1: CGPoint(x: 14.88, y: 21.24),
                   control2: CGPoint(x: 16.53, y: 20.55))
    path.addCurve(to: CGPoint(x: 19.43, y: 17.94),
                   control1: CGPoint(x: 18.35, y: 19.12),
                   control2: CGPoint(x: 19.11, y: 18.35))
    path.addCurve(to: CGPoint(x: 21.52, y: 11.96),
                   control1: CGPoint(x: 20.79, y: 16.24),
                   control2: CGPoint(x: 21.52, y: 14.15))
    path.addLine(to: CGPoint(x: 21.52, y: 11.57))
    path.addLine(to: CGPoint(x: 15.41, y: 11.57))
    path.addLine(to: CGPoint(x: 15.39, y: 11.64))
    path.addCurve(to: CGPoint(x: 15.23, y: 11.98),
                   control1: CGPoint(x: 15.37, y: 11.69),
                   control2: CGPoint(x: 15.3, y: 11.84))
    path.addCurve(to: CGPoint(x: 13, y: 13.83),
                   control1: CGPoint(x: 14.77, y: 12.87),
                   control2: CGPoint(x: 13.95, y: 13.56))
    path.addCurve(to: CGPoint(x: 10.96, y: 13.83),
                   control1: CGPoint(x: 12.34, y: 14.02),
                   control2: CGPoint(x: 11.61, y: 14.02))
    path.addCurve(to: CGPoint(x: 8.6, y: 11.73),
                   control1: CGPoint(x: 9.91, y: 13.53),
                   control2: CGPoint(x: 9.02, y: 12.74))
    path.addLine(to: CGPoint(x: 8.53, y: 11.57))
    path.addLine(to: CGPoint(x: 2.52, y: 11.57))
    path.addLine(to: CGPoint(x: 2.5, y: 11.74))
    path.addCurve(to: CGPoint(x: 2.55, y: 12.99),
                   control1: CGPoint(x: 2.48, y: 11.94),
                   control2: CGPoint(x: 2.5, y: 12.51))
    path.addCurve(to: CGPoint(x: 3.74, y: 16.71),
                   control1: CGPoint(x: 2.68, y: 14.27),
                   control2: CGPoint(x: 3.1, y: 15.57))
    path.addCurve(to: CGPoint(x: 4.1, y: 17.28),
                   control1: CGPoint(x: 3.8, y: 16.82),
                   control2: CGPoint(x: 3.96, y: 17.07))
    path.addCurve(to: CGPoint(x: 10.95, y: 21.45),
                   control1: CGPoint(x: 5.64, y: 19.61),
                   control2: CGPoint(x: 8.16, y: 21.14))
    path.addCurve(to: CGPoint(x: 12.15, y: 21.5),
                   control1: CGPoint(x: 11.46, y: 21.51),
                   control2: CGPoint(x: 11.48, y: 21.51))
    path.addCurve(to: CGPoint(x: 13.08, y: 21.46),
                   control1: CGPoint(x: 12.5, y: 21.5),
                   control2: CGPoint(x: 12.9, y: 21.48))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12.35, y: 12.52))
    path.addCurve(to: CGPoint(x: 13.98, y: 11.31),
                   control1: CGPoint(x: 13.06, y: 12.4),
                   control2: CGPoint(x: 13.66, y: 11.96))
    path.addCurve(to: CGPoint(x: 14.19, y: 10.32),
                   control1: CGPoint(x: 14.15, y: 10.95),
                   control2: CGPoint(x: 14.19, y: 10.77))
    path.addCurve(to: CGPoint(x: 14.14, y: 9.74),
                   control1: CGPoint(x: 14.19, y: 9.99),
                   control2: CGPoint(x: 14.18, y: 9.9))
    path.addCurve(to: CGPoint(x: 12.91, y: 8.29),
                   control1: CGPoint(x: 13.95, y: 9.09),
                   control2: CGPoint(x: 13.52, y: 8.58))
    path.addCurve(to: CGPoint(x: 9.97, y: 9.35),
                   control1: CGPoint(x: 11.81, y: 7.78),
                   control2: CGPoint(x: 10.5, y: 8.25))
    path.addCurve(to: CGPoint(x: 9.75, y: 10.11),
                   control1: CGPoint(x: 9.83, y: 9.63),
                   control2: CGPoint(x: 9.78, y: 9.82))
    path.addCurve(to: CGPoint(x: 9.96, y: 11.28),
                   control1: CGPoint(x: 9.72, y: 10.53),
                   control2: CGPoint(x: 9.78, y: 10.9))
    path.addCurve(to: CGPoint(x: 11.69, y: 12.54),
                   control1: CGPoint(x: 10.28, y: 11.96),
                   control2: CGPoint(x: 10.91, y: 12.42))
    path.addCurve(to: CGPoint(x: 12.35, y: 12.52),
                   control1: CGPoint(x: 11.83, y: 12.57),
                   control2: CGPoint(x: 12.16, y: 12.56))
    path.closeSubpath()
    path.move(to: CGPoint(x: 8.49, y: 9.21))
    path.addCurve(to: CGPoint(x: 9.04, y: 8.14),
                   control1: CGPoint(x: 8.57, y: 8.94),
                   control2: CGPoint(x: 8.85, y: 8.4))
    path.addCurve(to: CGPoint(x: 11.35, y: 6.72),
                   control1: CGPoint(x: 9.61, y: 7.39),
                   control2: CGPoint(x: 10.44, y: 6.88))
    path.addCurve(to: CGPoint(x: 12.55, y: 6.71),
                   control1: CGPoint(x: 11.68, y: 6.67),
                   control2: CGPoint(x: 12.23, y: 6.66))
    path.addCurve(to: CGPoint(x: 14.61, y: 7.8),
                   control1: CGPoint(x: 13.35, y: 6.84),
                   control2: CGPoint(x: 14.04, y: 7.21))
    path.addCurve(to: CGPoint(x: 15.45, y: 9.2),
                   control1: CGPoint(x: 14.99, y: 8.2),
                   control2: CGPoint(x: 15.29, y: 8.69))
    path.addLine(to: CGPoint(x: 15.52, y: 9.41))
    path.addLine(to: CGPoint(x: 21.15, y: 9.41))
    path.addLine(to: CGPoint(x: 21.14, y: 9.34))
    path.addCurve(to: CGPoint(x: 21, y: 8.93),
                   control1: CGPoint(x: 21.13, y: 9.31),
                   control2: CGPoint(x: 21.07, y: 9.12))
    path.addCurve(to: CGPoint(x: 19.27, y: 5.86),
                   control1: CGPoint(x: 20.61, y: 7.8),
                   control2: CGPoint(x: 20.05, y: 6.8))
    path.addCurve(to: CGPoint(x: 17.98, y: 4.61),
                   control1: CGPoint(x: 18.99, y: 5.53),
                   control2: CGPoint(x: 18.34, y: 4.9))
    path.addCurve(to: CGPoint(x: 15.08, y: 3.01),
                   control1: CGPoint(x: 17.1, y: 3.9),
                   control2: CGPoint(x: 16.15, y: 3.38))
    path.addCurve(to: CGPoint(x: 12.01, y: 2.5),
                   control1: CGPoint(x: 14.08, y: 2.67),
                   control2: CGPoint(x: 13.1, y: 2.51))
    path.addCurve(to: CGPoint(x: 9.35, y: 2.88),
                   control1: CGPoint(x: 11.06, y: 2.5),
                   control2: CGPoint(x: 10.23, y: 2.62))
    path.addCurve(to: CGPoint(x: 3.36, y: 8.05),
                   control1: CGPoint(x: 6.7, y: 3.65),
                   control2: CGPoint(x: 4.49, y: 5.56))
    path.addCurve(to: CGPoint(x: 2.92, y: 9.21),
                   control1: CGPoint(x: 3.2, y: 8.4),
                   control2: CGPoint(x: 3.01, y: 8.9))
    path.addLine(to: CGPoint(x: 2.86, y: 9.41))
    path.addLine(to: CGPoint(x: 8.43, y: 9.41))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}