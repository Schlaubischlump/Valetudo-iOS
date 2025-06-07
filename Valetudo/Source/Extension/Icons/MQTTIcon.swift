import CoreGraphics
import UIKit

extension UIImage {
  static func svgMqtticon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawMqtticon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawMqtticon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 20.09, y: 4.07))
    path.addCurve(to: CGPoint(x: 23, y: 7.51),
                   control1: CGPoint(x: 21.14, y: 5.11),
                   control2: CGPoint(x: 22.15, y: 6.35))
    path.addLine(to: CGPoint(x: 23, y: 2.1))
    path.addCurve(to: CGPoint(x: 21.9, y: 1),
                   control1: CGPoint(x: 23, y: 1.5),
                   control2: CGPoint(x: 22.51, y: 1))
    path.addLine(to: CGPoint(x: 16.34, y: 1))
    path.addCurve(to: CGPoint(x: 20.09, y: 4.07),
                   control1: CGPoint(x: 17.63, y: 1.91),
                   control2: CGPoint(x: 18.94, y: 2.93))
    path.closeSubpath()
    path.move(to: CGPoint(x: 22.99, y: 21.89))
    path.addLine(to: CGPoint(x: 22.99, y: 14.41))
    path.addCurve(to: CGPoint(x: 9.05, y: 1),
                   control1: CGPoint(x: 20.49, y: 8.2),
                   control2: CGPoint(x: 15.4, y: 3.29))
    path.addLine(to: CGPoint(x: 2.1, y: 1))
    path.addCurve(to: CGPoint(x: 1, y: 2.1),
                   control1: CGPoint(x: 1.5, y: 1),
                   control2: CGPoint(x: 1, y: 1.49))
    path.addLine(to: CGPoint(x: 1, y: 3.18))
    path.addCurve(to: CGPoint(x: 20.96, y: 23),
                   control1: CGPoint(x: 11.97, y: 3.24),
                   control2: CGPoint(x: 20.89, y: 12.1))
    path.addLine(to: CGPoint(x: 21.9, y: 23))
    path.addCurve(to: CGPoint(x: 22.99, y: 21.89),
                   control1: CGPoint(x: 22.5, y: 22.99),
                   control2: CGPoint(x: 22.99, y: 22.5))
    path.closeSubpath()
    path.move(to: CGPoint(x: 1, y: 6.54))
    path.addLine(to: CGPoint(x: 1, y: 10.12))
    path.addCurve(to: CGPoint(x: 13.97, y: 23),
                   control1: CGPoint(x: 8.12, y: 10.18),
                   control2: CGPoint(x: 13.9, y: 15.92))
    path.addLine(to: CGPoint(x: 17.69, y: 23))
    path.addCurve(to: CGPoint(x: 1, y: 6.54),
                   control1: CGPoint(x: 17.62, y: 13.91),
                   control2: CGPoint(x: 10.16, y: 6.54))
    path.closeSubpath()
    path.move(to: CGPoint(x: 1, y: 13.48))
    path.addLine(to: CGPoint(x: 1, y: 21.9))
    path.addCurve(to: CGPoint(x: 2.1, y: 23),
                   control1: CGPoint(x: 1, y: 22.5),
                   control2: CGPoint(x: 1.49, y: 23))
    path.addLine(to: CGPoint(x: 10.7, y: 23))
    path.addCurve(to: CGPoint(x: 1, y: 13.48),
                   control1: CGPoint(x: 10.63, y: 17.74),
                   control2: CGPoint(x: 6.31, y: 13.49))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}