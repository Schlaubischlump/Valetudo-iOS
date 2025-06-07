import CoreGraphics
import UIKit

extension UIImage {
  static func svgValetudomonochromeicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawValetudomonochromeicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawValetudomonochromeicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 11.77, y: 10.61))
    path.addCurve(to: CGPoint(x: 10.64, y: 10.16),
                   control1: CGPoint(x: 11.38, y: 10.57),
                   control2: CGPoint(x: 10.97, y: 10.4))
    path.addCurve(to: CGPoint(x: 10.2, y: 9.71),
                   control1: CGPoint(x: 10.52, y: 10.06),
                   control2: CGPoint(x: 10.29, y: 9.83))
    path.addCurve(to: CGPoint(x: 9.76, y: 8.72),
                   control1: CGPoint(x: 9.98, y: 9.42),
                   control2: CGPoint(x: 9.83, y: 9.07))
    path.addCurve(to: CGPoint(x: 9.74, y: 8.04),
                   control1: CGPoint(x: 9.73, y: 8.57),
                   control2: CGPoint(x: 9.72, y: 8.19))
    path.addCurve(to: CGPoint(x: 10.76, y: 6.38),
                   control1: CGPoint(x: 9.83, y: 7.36),
                   control2: CGPoint(x: 10.2, y: 6.76))
    path.addCurve(to: CGPoint(x: 11.67, y: 6.02),
                   control1: CGPoint(x: 11.04, y: 6.19),
                   control2: CGPoint(x: 11.33, y: 6.08))
    path.addCurve(to: CGPoint(x: 12.33, y: 6.02),
                   control1: CGPoint(x: 11.84, y: 5.99),
                   control2: CGPoint(x: 12.15, y: 5.99))
    path.addCurve(to: CGPoint(x: 14.25, y: 7.99),
                   control1: CGPoint(x: 13.33, y: 6.19),
                   control2: CGPoint(x: 14.1, y: 6.97))
    path.addCurve(to: CGPoint(x: 14.25, y: 8.63),
                   control1: CGPoint(x: 14.27, y: 8.15),
                   control2: CGPoint(x: 14.27, y: 8.47))
    path.addCurve(to: CGPoint(x: 13.23, y: 10.25),
                   control1: CGPoint(x: 14.16, y: 9.29),
                   control2: CGPoint(x: 13.79, y: 9.87))
    path.addCurve(to: CGPoint(x: 11.77, y: 10.61),
                   control1: CGPoint(x: 12.81, y: 10.53),
                   control2: CGPoint(x: 12.26, y: 10.67))
    path.closeSubpath()
    path.move(to: CGPoint(x: 11.72, y: 14.44))
    path.addCurve(to: CGPoint(x: 9.18, y: 12.99),
                   control1: CGPoint(x: 10.87, y: 14.05),
                   control2: CGPoint(x: 9.94, y: 13.52))
    path.addCurve(to: CGPoint(x: 6.82, y: 10.72),
                   control1: CGPoint(x: 8.12, y: 12.24),
                   control2: CGPoint(x: 7.34, y: 11.49))
    path.addCurve(to: CGPoint(x: 6.1, y: 8.36),
                   control1: CGPoint(x: 6.31, y: 9.95),
                   control2: CGPoint(x: 6.07, y: 9.16))
    path.addCurve(to: CGPoint(x: 6.73, y: 5.9),
                   control1: CGPoint(x: 6.14, y: 7.45),
                   control2: CGPoint(x: 6.33, y: 6.69))
    path.addCurve(to: CGPoint(x: 7.4, y: 4.84),
                   control1: CGPoint(x: 6.93, y: 5.5),
                   control2: CGPoint(x: 7.13, y: 5.18))
    path.addCurve(to: CGPoint(x: 11.26, y: 2.67),
                   control1: CGPoint(x: 8.36, y: 3.64),
                   control2: CGPoint(x: 9.75, y: 2.86))
    path.addCurve(to: CGPoint(x: 12.68, y: 2.66),
                   control1: CGPoint(x: 11.69, y: 2.62),
                   control2: CGPoint(x: 12.27, y: 2.61))
    path.addCurve(to: CGPoint(x: 17.03, y: 5.44),
                   control1: CGPoint(x: 14.49, y: 2.88),
                   control2: CGPoint(x: 16.06, y: 3.89))
    path.addCurve(to: CGPoint(x: 17.48, y: 6.35),
                   control1: CGPoint(x: 17.16, y: 5.66),
                   control2: CGPoint(x: 17.39, y: 6.11))
    path.addCurve(to: CGPoint(x: 17.9, y: 8.38),
                   control1: CGPoint(x: 17.74, y: 7),
                   control2: CGPoint(x: 17.87, y: 7.64))
    path.addCurve(to: CGPoint(x: 15.2, y: 12.71),
                   control1: CGPoint(x: 17.96, y: 9.87),
                   control2: CGPoint(x: 17.06, y: 11.32))
    path.addCurve(to: CGPoint(x: 13, y: 14.09),
                   control1: CGPoint(x: 14.53, y: 13.21),
                   control2: CGPoint(x: 13.84, y: 13.65))
    path.addCurve(to: CGPoint(x: 12, y: 14.55),
                   control1: CGPoint(x: 12.67, y: 14.26),
                   control2: CGPoint(x: 12.04, y: 14.55))
    path.addCurve(to: CGPoint(x: 11.72, y: 14.44),
                   control1: CGPoint(x: 11.99, y: 14.55),
                   control2: CGPoint(x: 11.87, y: 14.5))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12.22, y: 12.28))
    path.addCurve(to: CGPoint(x: 14.27, y: 10.95),
                   control1: CGPoint(x: 12.97, y: 11.88),
                   control2: CGPoint(x: 13.7, y: 11.41))
    path.addCurve(to: CGPoint(x: 15.92, y: 8.79),
                   control1: CGPoint(x: 15.22, y: 10.19),
                   control2: CGPoint(x: 15.8, y: 9.44))
    path.addCurve(to: CGPoint(x: 15.9, y: 7.97),
                   control1: CGPoint(x: 15.95, y: 8.64),
                   control2: CGPoint(x: 15.94, y: 8.21))
    path.addCurve(to: CGPoint(x: 14.16, y: 5.23),
                   control1: CGPoint(x: 15.73, y: 6.83),
                   control2: CGPoint(x: 15.11, y: 5.87))
    path.addCurve(to: CGPoint(x: 12.49, y: 4.61),
                   control1: CGPoint(x: 13.67, y: 4.91),
                   control2: CGPoint(x: 13.11, y: 4.7))
    path.addCurve(to: CGPoint(x: 11.52, y: 4.61),
                   control1: CGPoint(x: 12.27, y: 4.58),
                   control2: CGPoint(x: 11.73, y: 4.58))
    path.addCurve(to: CGPoint(x: 10.24, y: 5.01),
                   control1: CGPoint(x: 11.03, y: 4.68),
                   control2: CGPoint(x: 10.66, y: 4.79))
    path.addCurve(to: CGPoint(x: 8.12, y: 7.82),
                   control1: CGPoint(x: 9.14, y: 5.55),
                   control2: CGPoint(x: 8.35, y: 6.6))
    path.addCurve(to: CGPoint(x: 8.08, y: 8.8),
                   control1: CGPoint(x: 8.06, y: 8.14),
                   control2: CGPoint(x: 8.04, y: 8.59))
    path.addCurve(to: CGPoint(x: 11.74, y: 12.26),
                   control1: CGPoint(x: 8.28, y: 9.83),
                   control2: CGPoint(x: 9.65, y: 11.13))
    path.addCurve(to: CGPoint(x: 12, y: 12.4),
                   control1: CGPoint(x: 11.88, y: 12.33),
                   control2: CGPoint(x: 12, y: 12.4))
    path.addCurve(to: CGPoint(x: 12.22, y: 12.28),
                   control1: CGPoint(x: 12, y: 12.4),
                   control2: CGPoint(x: 12.1, y: 12.34))
    path.closeSubpath()
    path.move(to: CGPoint(x: 11.25, y: 22.22))
    path.addCurve(to: CGPoint(x: 10.21, y: 20.67),
                   control1: CGPoint(x: 10.51, y: 21.05),
                   control2: CGPoint(x: 10.41, y: 20.9))
    path.addCurve(to: CGPoint(x: 9.46, y: 19.92),
                   control1: CGPoint(x: 10.08, y: 20.51),
                   control2: CGPoint(x: 9.65, y: 20.08))
    path.addCurve(to: CGPoint(x: 6.44, y: 17.74),
                   control1: CGPoint(x: 8.71, y: 19.25),
                   control2: CGPoint(x: 7.94, y: 18.7))
    path.addCurve(to: CGPoint(x: 4.63, y: 16.39),
                   control1: CGPoint(x: 5.84, y: 17.35),
                   control2: CGPoint(x: 5.17, y: 16.85))
    path.addCurve(to: CGPoint(x: 3.29, y: 15.09),
                   control1: CGPoint(x: 4.23, y: 16.05),
                   control2: CGPoint(x: 3.62, y: 15.46))
    path.addCurve(to: CGPoint(x: 0, y: 6.87),
                   control1: CGPoint(x: 1.13, y: 12.7),
                   control2: CGPoint(x: 0, y: 9.89))
    path.addCurve(to: CGPoint(x: 1.07, y: 1.89),
                   control1: CGPoint(x: -0, y: 5.14),
                   control2: CGPoint(x: 0.36, y: 3.46))
    path.addCurve(to: CGPoint(x: 1.77, y: 0.6),
                   control1: CGPoint(x: 1.3, y: 1.39),
                   control2: CGPoint(x: 1.74, y: 0.58))
    path.addCurve(to: CGPoint(x: 4.62, y: 2.35),
                   control1: CGPoint(x: 1.94, y: 0.7),
                   control2: CGPoint(x: 4.62, y: 2.34))
    path.addCurve(to: CGPoint(x: 4.51, y: 2.56),
                   control1: CGPoint(x: 4.62, y: 2.35),
                   control2: CGPoint(x: 4.57, y: 2.45))
    path.addCurve(to: CGPoint(x: 3.45, y: 8.07),
                   control1: CGPoint(x: 3.55, y: 4.22),
                   control2: CGPoint(x: 3.18, y: 6.17))
    path.addCurve(to: CGPoint(x: 7.46, y: 14.34),
                   control1: CGPoint(x: 3.79, y: 10.45),
                   control2: CGPoint(x: 5.19, y: 12.64))
    path.addCurve(to: CGPoint(x: 8.43, y: 15.01),
                   control1: CGPoint(x: 7.78, y: 14.59),
                   control2: CGPoint(x: 8, y: 14.74))
    path.addCurve(to: CGPoint(x: 10.48, y: 16.41),
                   control1: CGPoint(x: 9.33, y: 15.59),
                   control2: CGPoint(x: 9.85, y: 15.94))
    path.addCurve(to: CGPoint(x: 11.94, y: 17.62),
                   control1: CGPoint(x: 11.04, y: 16.83),
                   control2: CGPoint(x: 11.4, y: 17.13))
    path.addLine(to: CGPoint(x: 12, y: 17.67))
    path.addLine(to: CGPoint(x: 12.05, y: 17.63))
    path.addCurve(to: CGPoint(x: 15.65, y: 14.96),
                   control1: CGPoint(x: 13.16, y: 16.63),
                   control2: CGPoint(x: 13.96, y: 16.05))
    path.addCurve(to: CGPoint(x: 19.74, y: 10.63),
                   control1: CGPoint(x: 17.53, y: 13.76),
                   control2: CGPoint(x: 18.91, y: 12.3))
    path.addCurve(to: CGPoint(x: 20.6, y: 6.04),
                   control1: CGPoint(x: 20.46, y: 9.19),
                   control2: CGPoint(x: 20.75, y: 7.63))
    path.addCurve(to: CGPoint(x: 19.49, y: 2.55),
                   control1: CGPoint(x: 20.48, y: 4.8),
                   control2: CGPoint(x: 20.1, y: 3.62))
    path.addCurve(to: CGPoint(x: 19.38, y: 2.35),
                   control1: CGPoint(x: 19.43, y: 2.44),
                   control2: CGPoint(x: 19.38, y: 2.35))
    path.addCurve(to: CGPoint(x: 19.62, y: 2.2),
                   control1: CGPoint(x: 19.38, y: 2.34),
                   control2: CGPoint(x: 19.49, y: 2.27))
    path.addCurve(to: CGPoint(x: 22.22, y: 0.61),
                   control1: CGPoint(x: 19.89, y: 2.03),
                   control2: CGPoint(x: 22.18, y: 0.63))
    path.addCurve(to: CGPoint(x: 22.34, y: 0.76),
                   control1: CGPoint(x: 22.24, y: 0.59),
                   control2: CGPoint(x: 22.25, y: 0.6))
    path.addCurve(to: CGPoint(x: 24, y: 6.87),
                   control1: CGPoint(x: 23.44, y: 2.62),
                   control2: CGPoint(x: 24, y: 4.7))
    path.addCurve(to: CGPoint(x: 20.98, y: 14.79),
                   control1: CGPoint(x: 24, y: 9.75),
                   control2: CGPoint(x: 22.96, y: 12.48))
    path.addCurve(to: CGPoint(x: 19.51, y: 16.27),
                   control1: CGPoint(x: 20.56, y: 15.27),
                   control2: CGPoint(x: 19.99, y: 15.85))
    path.addCurve(to: CGPoint(x: 17.34, y: 17.88),
                   control1: CGPoint(x: 18.85, y: 16.85),
                   control2: CGPoint(x: 18.23, y: 17.31))
    path.addCurve(to: CGPoint(x: 13.59, y: 20.91),
                   control1: CGPoint(x: 15.38, y: 19.13),
                   control2: CGPoint(x: 14.22, y: 20.08))
    path.addCurve(to: CGPoint(x: 12.75, y: 22.22),
                   control1: CGPoint(x: 13.54, y: 20.98),
                   control2: CGPoint(x: 13.16, y: 21.57))
    path.addCurve(to: CGPoint(x: 12, y: 23.4),
                   control1: CGPoint(x: 12.34, y: 22.87),
                   control2: CGPoint(x: 12.01, y: 23.4))
    path.addCurve(to: CGPoint(x: 11.25, y: 22.22),
                   control1: CGPoint(x: 11.99, y: 23.4),
                   control2: CGPoint(x: 11.66, y: 22.87))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}