import CoreGraphics
import UIKit

extension UIImage {
  static func svgVirtualrestrictionsicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawVirtualrestrictionsicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawVirtualrestrictionsicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 6.91, y: 5.5))
    path.addLine(to: CGPoint(x: 9.21, y: 7.79))
    path.addLine(to: CGPoint(x: 7.79, y: 9.21))
    path.addLine(to: CGPoint(x: 5.5, y: 6.91))
    path.addLine(to: CGPoint(x: 3.21, y: 9.21))
    path.addLine(to: CGPoint(x: 1.79, y: 7.79))
    path.addLine(to: CGPoint(x: 4.09, y: 5.5))
    path.addLine(to: CGPoint(x: 1.79, y: 3.21))
    path.addLine(to: CGPoint(x: 3.21, y: 1.79))
    path.addLine(to: CGPoint(x: 5.5, y: 4.09))
    path.addLine(to: CGPoint(x: 7.79, y: 1.79))
    path.addLine(to: CGPoint(x: 9.21, y: 3.21))
    path.move(to: CGPoint(x: 22.21, y: 16.21))
    path.addLine(to: CGPoint(x: 20.79, y: 14.79))
    path.addLine(to: CGPoint(x: 18.5, y: 17.09))
    path.addLine(to: CGPoint(x: 16.21, y: 14.79))
    path.addLine(to: CGPoint(x: 14.79, y: 16.21))
    path.addLine(to: CGPoint(x: 17.09, y: 18.5))
    path.addLine(to: CGPoint(x: 14.79, y: 20.79))
    path.addLine(to: CGPoint(x: 16.21, y: 22.21))
    path.addLine(to: CGPoint(x: 18.5, y: 19.91))
    path.addLine(to: CGPoint(x: 20.79, y: 22.21))
    path.addLine(to: CGPoint(x: 22.21, y: 20.79))
    path.addLine(to: CGPoint(x: 19.91, y: 18.5))
    path.move(to: CGPoint(x: 20.4, y: 6.83))
    path.addLine(to: CGPoint(x: 17.18, y: 11))
    path.addLine(to: CGPoint(x: 15.6, y: 9.73))
    path.addLine(to: CGPoint(x: 16.77, y: 8.23))
    path.addCurve(to: CGPoint(x: 10.11, y: 13.85),
                   control1: CGPoint(x: 13.74, y: 8.85),
                   control2: CGPoint(x: 11.23, y: 10.96))
    path.addCurve(to: CGPoint(x: 11.49, y: 19.54),
                   control1: CGPoint(x: 11.91, y: 15.15),
                   control2: CGPoint(x: 12.49, y: 17.56))
    path.addCurve(to: CGPoint(x: 6.08, y: 21.78),
                   control1: CGPoint(x: 10.49, y: 21.51),
                   control2: CGPoint(x: 8.19, y: 22.47))
    path.addCurve(to: CGPoint(x: 3.04, y: 16.78),
                   control1: CGPoint(x: 3.98, y: 21.09),
                   control2: CGPoint(x: 2.68, y: 18.97))
    path.addCurve(to: CGPoint(x: 7.5, y: 13),
                   control1: CGPoint(x: 3.39, y: 14.59),
                   control2: CGPoint(x: 5.28, y: 12.99))
    path.addCurve(to: CGPoint(x: 8.28, y: 13.08),
                   control1: CGPoint(x: 7.76, y: 13),
                   control2: CGPoint(x: 8.02, y: 13.03))
    path.addCurve(to: CGPoint(x: 16.43, y: 6.26),
                   control1: CGPoint(x: 9.69, y: 9.59),
                   control2: CGPoint(x: 12.74, y: 7.03))
    path.addLine(to: CGPoint(x: 15, y: 5.18))
    path.addLine(to: CGPoint(x: 16.27, y: 3.6))
    path.move(to: CGPoint(x: 10, y: 17.5))
    path.addCurve(to: CGPoint(x: 7.5, y: 15),
                   control1: CGPoint(x: 10, y: 16.12),
                   control2: CGPoint(x: 8.88, y: 15))
    path.addCurve(to: CGPoint(x: 5, y: 17.5),
                   control1: CGPoint(x: 6.12, y: 15),
                   control2: CGPoint(x: 5, y: 16.12))
    path.addCurve(to: CGPoint(x: 7.5, y: 20),
                   control1: CGPoint(x: 5, y: 18.88),
                   control2: CGPoint(x: 6.12, y: 20))
    path.addCurve(to: CGPoint(x: 9.27, y: 19.27),
                   control1: CGPoint(x: 8.16, y: 20),
                   control2: CGPoint(x: 8.8, y: 19.74))
    path.addCurve(to: CGPoint(x: 10, y: 17.5),
                   control1: CGPoint(x: 9.74, y: 18.8),
                   control2: CGPoint(x: 10, y: 18.16))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}