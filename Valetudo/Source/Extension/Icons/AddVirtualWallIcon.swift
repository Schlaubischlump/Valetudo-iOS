import CoreGraphics
import UIKit

extension UIImage {
  static func svgAddvirtualwallicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawAddvirtualwallicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawAddvirtualwallicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 3, y: 4))
    path.addLine(to: CGPoint(x: 3, y: 9))
    path.addLine(to: CGPoint(x: 11, y: 9))
    path.addLine(to: CGPoint(x: 11, y: 4))
    path.addLine(to: CGPoint(x: 3, y: 4))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12, y: 4))
    path.addLine(to: CGPoint(x: 12, y: 9))
    path.addLine(to: CGPoint(x: 21, y: 9))
    path.addLine(to: CGPoint(x: 21, y: 4))
    path.addLine(to: CGPoint(x: 12, y: 4))
    path.closeSubpath()
    path.move(to: CGPoint(x: 2, y: 10))
    path.addLine(to: CGPoint(x: 2, y: 15))
    path.addLine(to: CGPoint(x: 8, y: 15))
    path.addLine(to: CGPoint(x: 8, y: 10))
    path.addLine(to: CGPoint(x: 2, y: 10))
    path.closeSubpath()
    path.move(to: CGPoint(x: 9, y: 10))
    path.addLine(to: CGPoint(x: 9, y: 15))
    path.addLine(to: CGPoint(x: 14.54, y: 15))
    path.addCurve(to: CGPoint(x: 15, y: 14.54),
                   control1: CGPoint(x: 14.68, y: 14.84),
                   control2: CGPoint(x: 14.84, y: 14.68))
    path.addLine(to: CGPoint(x: 15, y: 10))
    path.addLine(to: CGPoint(x: 9, y: 10))
    path.closeSubpath()
    path.move(to: CGPoint(x: 16, y: 10))
    path.addLine(to: CGPoint(x: 16, y: 13.82))
    path.addCurve(to: CGPoint(x: 19, y: 13),
                   control1: CGPoint(x: 16.91, y: 13.29),
                   control2: CGPoint(x: 17.95, y: 13.01))
    path.addCurve(to: CGPoint(x: 22, y: 13.81),
                   control1: CGPoint(x: 20.05, y: 13),
                   control2: CGPoint(x: 21.09, y: 13.28))
    path.addLine(to: CGPoint(x: 22, y: 10))
    path.addLine(to: CGPoint(x: 16, y: 10))
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
    path.move(to: CGPoint(x: 3, y: 16))
    path.addLine(to: CGPoint(x: 3, y: 21))
    path.addLine(to: CGPoint(x: 12, y: 21))
    path.addLine(to: CGPoint(x: 12, y: 16))
    path.addLine(to: CGPoint(x: 3, y: 16))
    path.closeSubpath()
    path.move(to: CGPoint(x: 13, y: 16))
    path.addLine(to: CGPoint(x: 13, y: 19))
    path.addCurve(to: CGPoint(x: 13.82, y: 16),
                   control1: CGPoint(x: 13, y: 17.95),
                   control2: CGPoint(x: 13.29, y: 16.91))
    path.addLine(to: CGPoint(x: 13, y: 16))
    path.closeSubpath()
    path.move(to: CGPoint(x: 13, y: 19))
    path.addLine(to: CGPoint(x: 13, y: 21))
    path.addLine(to: CGPoint(x: 13.36, y: 21))
    path.addCurve(to: CGPoint(x: 13, y: 19),
                   control1: CGPoint(x: 13.13, y: 20.36),
                   control2: CGPoint(x: 13.01, y: 19.68))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}