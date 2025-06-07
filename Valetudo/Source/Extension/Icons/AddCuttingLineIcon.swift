import CoreGraphics
import UIKit

extension UIImage {
  static func svgAddcuttinglineicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawAddcuttinglineicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawAddcuttinglineicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 6, y: 2))
    path.addCurve(to: CGPoint(x: 3.17, y: 3.17),
                   control1: CGPoint(x: 4.94, y: 2),
                   control2: CGPoint(x: 3.92, y: 2.42))
    path.addCurve(to: CGPoint(x: 2, y: 6),
                   control1: CGPoint(x: 2.42, y: 3.92),
                   control2: CGPoint(x: 2, y: 4.94))
    path.addCurve(to: CGPoint(x: 6, y: 10),
                   control1: CGPoint(x: 2, y: 8.21),
                   control2: CGPoint(x: 3.79, y: 10))
    path.addCurve(to: CGPoint(x: 7.64, y: 9.64),
                   control1: CGPoint(x: 6.59, y: 10),
                   control2: CGPoint(x: 7.14, y: 9.87))
    path.addLine(to: CGPoint(x: 10, y: 12))
    path.addLine(to: CGPoint(x: 7.64, y: 14.36))
    path.addCurve(to: CGPoint(x: 6, y: 14),
                   control1: CGPoint(x: 7.14, y: 14.13),
                   control2: CGPoint(x: 6.59, y: 14))
    path.addCurve(to: CGPoint(x: 3.17, y: 15.17),
                   control1: CGPoint(x: 4.94, y: 14),
                   control2: CGPoint(x: 3.92, y: 14.42))
    path.addCurve(to: CGPoint(x: 2, y: 18),
                   control1: CGPoint(x: 2.42, y: 15.92),
                   control2: CGPoint(x: 2, y: 16.94))
    path.addCurve(to: CGPoint(x: 3.17, y: 20.83),
                   control1: CGPoint(x: 2, y: 19.06),
                   control2: CGPoint(x: 2.42, y: 20.08))
    path.addCurve(to: CGPoint(x: 6, y: 22),
                   control1: CGPoint(x: 3.92, y: 21.58),
                   control2: CGPoint(x: 4.94, y: 22))
    path.addCurve(to: CGPoint(x: 10, y: 18),
                   control1: CGPoint(x: 8.21, y: 22),
                   control2: CGPoint(x: 10, y: 20.21))
    path.addCurve(to: CGPoint(x: 9.64, y: 16.36),
                   control1: CGPoint(x: 10, y: 17.41),
                   control2: CGPoint(x: 9.87, y: 16.86))
    path.addLine(to: CGPoint(x: 12, y: 14))
    path.addLine(to: CGPoint(x: 13.88, y: 15.88))
    path.addCurve(to: CGPoint(x: 15.88, y: 13.88),
                   control1: CGPoint(x: 14.38, y: 15.07),
                   control2: CGPoint(x: 15.07, y: 14.38))
    path.addLine(to: CGPoint(x: 9.64, y: 7.64))
    path.addCurve(to: CGPoint(x: 10, y: 6),
                   control1: CGPoint(x: 9.87, y: 7.14),
                   control2: CGPoint(x: 10, y: 6.59))
    path.addCurve(to: CGPoint(x: 8.83, y: 3.17),
                   control1: CGPoint(x: 10, y: 4.94),
                   control2: CGPoint(x: 9.58, y: 3.92))
    path.addCurve(to: CGPoint(x: 6, y: 2),
                   control1: CGPoint(x: 8.08, y: 2.42),
                   control2: CGPoint(x: 7.06, y: 2))
    path.closeSubpath()
    path.move(to: CGPoint(x: 19, y: 3))
    path.addLine(to: CGPoint(x: 13, y: 9))
    path.addLine(to: CGPoint(x: 15, y: 11))
    path.addLine(to: CGPoint(x: 22, y: 4))
    path.addLine(to: CGPoint(x: 22, y: 3))
    path.addLine(to: CGPoint(x: 19, y: 3))
    path.closeSubpath()
    path.move(to: CGPoint(x: 6, y: 4))
    path.addCurve(to: CGPoint(x: 7.41, y: 4.59),
                   control1: CGPoint(x: 6.53, y: 4),
                   control2: CGPoint(x: 7.04, y: 4.21))
    path.addCurve(to: CGPoint(x: 8, y: 6),
                   control1: CGPoint(x: 7.79, y: 4.96),
                   control2: CGPoint(x: 8, y: 5.47))
    path.addCurve(to: CGPoint(x: 6, y: 8),
                   control1: CGPoint(x: 8, y: 7.11),
                   control2: CGPoint(x: 7.1, y: 8))
    path.addCurve(to: CGPoint(x: 4.59, y: 7.41),
                   control1: CGPoint(x: 5.47, y: 8),
                   control2: CGPoint(x: 4.96, y: 7.79))
    path.addCurve(to: CGPoint(x: 4, y: 6),
                   control1: CGPoint(x: 4.21, y: 7.04),
                   control2: CGPoint(x: 4, y: 6.53))
    path.addCurve(to: CGPoint(x: 6, y: 4),
                   control1: CGPoint(x: 4, y: 4.89),
                   control2: CGPoint(x: 4.9, y: 4))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12, y: 11.5))
    path.addCurve(to: CGPoint(x: 12.35, y: 11.65),
                   control1: CGPoint(x: 12.13, y: 11.5),
                   control2: CGPoint(x: 12.26, y: 11.55))
    path.addCurve(to: CGPoint(x: 12.5, y: 12),
                   control1: CGPoint(x: 12.45, y: 11.74),
                   control2: CGPoint(x: 12.5, y: 11.87))
    path.addCurve(to: CGPoint(x: 12.35, y: 12.35),
                   control1: CGPoint(x: 12.5, y: 12.13),
                   control2: CGPoint(x: 12.45, y: 12.26))
    path.addCurve(to: CGPoint(x: 12, y: 12.5),
                   control1: CGPoint(x: 12.26, y: 12.45),
                   control2: CGPoint(x: 12.13, y: 12.5))
    path.addCurve(to: CGPoint(x: 11.65, y: 12.35),
                   control1: CGPoint(x: 11.87, y: 12.5),
                   control2: CGPoint(x: 11.74, y: 12.45))
    path.addCurve(to: CGPoint(x: 11.5, y: 12),
                   control1: CGPoint(x: 11.55, y: 12.26),
                   control2: CGPoint(x: 11.5, y: 12.13))
    path.addCurve(to: CGPoint(x: 11.65, y: 11.65),
                   control1: CGPoint(x: 11.5, y: 11.87),
                   control2: CGPoint(x: 11.55, y: 11.74))
    path.addCurve(to: CGPoint(x: 12, y: 11.5),
                   control1: CGPoint(x: 11.74, y: 11.55),
                   control2: CGPoint(x: 11.87, y: 11.5))
    path.closeSubpath()
    path.move(to: CGPoint(x: 18, y: 15))
    path.addLine(to: CGPoint(x: 18, y: 18))
    path.addLine(to: CGPoint(x: 15, y: 18))
    path.addLine(to: CGPoint(x: 15, y: 20))
    path.addLine(to: CGPoint(x: 18, y: 20))
    path.addLine(to: CGPoint(x: 18, y: 23))
    path.addLine(to: CGPoint(x: 20, y: 23))
    path.addLine(to: CGPoint(x: 20, y: 20))
    path.addLine(to: CGPoint(x: 23, y: 20))
    path.addLine(to: CGPoint(x: 23, y: 18))
    path.addLine(to: CGPoint(x: 20, y: 18))
    path.addLine(to: CGPoint(x: 20, y: 15))
    path.addLine(to: CGPoint(x: 18, y: 15))
    path.closeSubpath()
    path.move(to: CGPoint(x: 6, y: 16))
    path.addCurve(to: CGPoint(x: 7.41, y: 16.59),
                   control1: CGPoint(x: 6.53, y: 16),
                   control2: CGPoint(x: 7.04, y: 16.21))
    path.addCurve(to: CGPoint(x: 8, y: 18),
                   control1: CGPoint(x: 7.79, y: 16.96),
                   control2: CGPoint(x: 8, y: 17.47))
    path.addCurve(to: CGPoint(x: 6, y: 20),
                   control1: CGPoint(x: 8, y: 19.11),
                   control2: CGPoint(x: 7.1, y: 20))
    path.addCurve(to: CGPoint(x: 4.59, y: 19.41),
                   control1: CGPoint(x: 5.47, y: 20),
                   control2: CGPoint(x: 4.96, y: 19.79))
    path.addCurve(to: CGPoint(x: 4, y: 18),
                   control1: CGPoint(x: 4.21, y: 19.04),
                   control2: CGPoint(x: 4, y: 18.53))
    path.addCurve(to: CGPoint(x: 6, y: 16),
                   control1: CGPoint(x: 4, y: 16.89),
                   control2: CGPoint(x: 4.9, y: 16))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}