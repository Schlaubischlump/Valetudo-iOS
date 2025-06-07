import CoreGraphics
import UIKit

extension UIImage {
  static func waterGradeHigh(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawWatergradehighicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawWatergradehighicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setFillColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 9.87, y: 0.01))
    path.addLine(to: CGPoint(x: 9.05, y: 0.98))
    path.addCurve(to: CGPoint(x: 5.25, y: 6.16),
                   control1: CGPoint(x: 9.05, y: 0.98),
                   control2: CGPoint(x: 7.15, y: 3.25))
    path.addCurve(to: CGPoint(x: 1.35, y: 15.49),
                   control1: CGPoint(x: 3.35, y: 9.06),
                   control2: CGPoint(x: 1.35, y: 12.5))
    path.addCurve(to: CGPoint(x: 9.87, y: 24),
                   control1: CGPoint(x: 1.35, y: 20.18),
                   control2: CGPoint(x: 5.18, y: 24))
    path.addCurve(to: CGPoint(x: 12.45, y: 23.6),
                   control1: CGPoint(x: 10.77, y: 24),
                   control2: CGPoint(x: 11.63, y: 23.86))
    path.addCurve(to: CGPoint(x: 9.16, y: 17.62),
                   control1: CGPoint(x: 10.47, y: 22.34),
                   control2: CGPoint(x: 9.16, y: 20.13))
    path.addCurve(to: CGPoint(x: 12.2, y: 10.23),
                   control1: CGPoint(x: 9.16, y: 15.06),
                   control2: CGPoint(x: 10.75, y: 12.43))
    path.addCurve(to: CGPoint(x: 14.79, y: 6.65),
                   control1: CGPoint(x: 13.26, y: 8.61),
                   control2: CGPoint(x: 14.3, y: 7.26))
    path.addCurve(to: CGPoint(x: 14.48, y: 6.16),
                   control1: CGPoint(x: 14.69, y: 6.48),
                   control2: CGPoint(x: 14.58, y: 6.32))
    path.addCurve(to: CGPoint(x: 10.68, y: 0.98),
                   control1: CGPoint(x: 12.58, y: 3.25),
                   control2: CGPoint(x: 10.68, y: 0.98))
    path.addLine(to: CGPoint(x: 9.87, y: 0.01))
    path.closeSubpath()
    path.move(to: CGPoint(x: 16.25, y: 6.01))
    path.addLine(to: CGPoint(x: 15.63, y: 6.74))
    path.addCurve(to: CGPoint(x: 12.79, y: 10.62),
                   control1: CGPoint(x: 15.63, y: 6.74),
                   control2: CGPoint(x: 14.21, y: 8.44))
    path.addCurve(to: CGPoint(x: 9.87, y: 17.62),
                   control1: CGPoint(x: 11.36, y: 12.79),
                   control2: CGPoint(x: 9.87, y: 15.38))
    path.addCurve(to: CGPoint(x: 16.25, y: 24),
                   control1: CGPoint(x: 9.87, y: 21.14),
                   control2: CGPoint(x: 12.73, y: 24))
    path.addCurve(to: CGPoint(x: 22.63, y: 17.62),
                   control1: CGPoint(x: 19.76, y: 24),
                   control2: CGPoint(x: 22.63, y: 21.14))
    path.addCurve(to: CGPoint(x: 22.15, y: 15.19),
                   control1: CGPoint(x: 22.63, y: 16.84),
                   control2: CGPoint(x: 22.45, y: 16.02))
    path.addCurve(to: CGPoint(x: 19.71, y: 10.62),
                   control1: CGPoint(x: 21.6, y: 13.63),
                   control2: CGPoint(x: 20.64, y: 12.04))
    path.addCurve(to: CGPoint(x: 16.86, y: 6.74),
                   control1: CGPoint(x: 18.28, y: 8.44),
                   control2: CGPoint(x: 16.86, y: 6.74))
    path.addLine(to: CGPoint(x: 16.25, y: 6.01))
    path.closeSubpath()
    path.move(to: CGPoint(x: 16.25, y: 8.6))
    path.addCurve(to: CGPoint(x: 18.37, y: 11.49),
                   control1: CGPoint(x: 16.67, y: 9.12),
                   control2: CGPoint(x: 17.31, y: 9.87))
    path.addCurve(to: CGPoint(x: 21.03, y: 17.62),
                   control1: CGPoint(x: 19.74, y: 13.58),
                   control2: CGPoint(x: 21.03, y: 16.18))
    path.addCurve(to: CGPoint(x: 21.02, y: 18.04),
                   control1: CGPoint(x: 21.03, y: 17.76),
                   control2: CGPoint(x: 21.03, y: 17.9))
    path.addCurve(to: CGPoint(x: 20.66, y: 18.22),
                   control1: CGPoint(x: 20.98, y: 18.12),
                   control2: CGPoint(x: 20.84, y: 18.19))
    path.addCurve(to: CGPoint(x: 20.34, y: 18.2),
                   control1: CGPoint(x: 20.61, y: 18.23),
                   control2: CGPoint(x: 20.4, y: 18.22))
    path.addCurve(to: CGPoint(x: 18.87, y: 17.36),
                   control1: CGPoint(x: 19.95, y: 18.12),
                   control2: CGPoint(x: 19.52, y: 17.87))
    path.addCurve(to: CGPoint(x: 18.06, y: 16.71),
                   control1: CGPoint(x: 18.65, y: 17.19),
                   control2: CGPoint(x: 18.56, y: 17.12))
    path.addCurve(to: CGPoint(x: 15.96, y: 15.15),
                   control1: CGPoint(x: 16.99, y: 15.82),
                   control2: CGPoint(x: 16.53, y: 15.48))
    path.addCurve(to: CGPoint(x: 13.94, y: 14.55),
                   control1: CGPoint(x: 15.24, y: 14.74),
                   control2: CGPoint(x: 14.57, y: 14.54))
    path.addCurve(to: CGPoint(x: 12.14, y: 15.19),
                   control1: CGPoint(x: 13.3, y: 14.55),
                   control2: CGPoint(x: 12.7, y: 14.77))
    path.addCurve(to: CGPoint(x: 12.07, y: 15.28),
                   control1: CGPoint(x: 12.12, y: 15.21),
                   control2: CGPoint(x: 12.1, y: 15.24))
    path.addCurve(to: CGPoint(x: 14.12, y: 11.49),
                   control1: CGPoint(x: 12.58, y: 14.06),
                   control2: CGPoint(x: 13.34, y: 12.69))
    path.addCurve(to: CGPoint(x: 16.25, y: 8.6),
                   control1: CGPoint(x: 15.18, y: 9.87),
                   control2: CGPoint(x: 15.83, y: 9.12))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
  }
}
