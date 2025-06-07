import CoreGraphics
import UIKit

extension UIImage {
  static func svgAddnomopareaicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawAddnomopareaicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawAddnomopareaicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 2.39, y: 1.73))
    path.addLine(to: CGPoint(x: 1.11, y: 3))
    path.addLine(to: CGPoint(x: 7.55, y: 9.44))
    path.addCurve(to: CGPoint(x: 6, y: 14),
                   control1: CGPoint(x: 6.67, y: 11.03),
                   control2: CGPoint(x: 6, y: 12.67))
    path.addCurve(to: CGPoint(x: 12, y: 20),
                   control1: CGPoint(x: 6, y: 17.31),
                   control2: CGPoint(x: 8.69, y: 20))
    path.addCurve(to: CGPoint(x: 13.07, y: 19.9),
                   control1: CGPoint(x: 12.37, y: 20),
                   control2: CGPoint(x: 12.72, y: 19.97))
    path.addCurve(to: CGPoint(x: 13, y: 19),
                   control1: CGPoint(x: 13.02, y: 19.6),
                   control2: CGPoint(x: 13, y: 19.3))
    path.addCurve(to: CGPoint(x: 15.1, y: 14.44),
                   control1: CGPoint(x: 13, y: 17.25),
                   control2: CGPoint(x: 13.77, y: 15.58))
    path.addLine(to: CGPoint(x: 2.39, y: 1.73))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12, y: 3.25))
    path.addCurve(to: CGPoint(x: 9.55, y: 6.35),
                   control1: CGPoint(x: 12, y: 3.25),
                   control2: CGPoint(x: 10.84, y: 4.55))
    path.addLine(to: CGPoint(x: 16.68, y: 13.48))
    path.addCurve(to: CGPoint(x: 17.91, y: 13.11),
                   control1: CGPoint(x: 17.07, y: 13.31),
                   control2: CGPoint(x: 17.49, y: 13.19))
    path.addCurve(to: CGPoint(x: 12, y: 3.25),
                   control1: CGPoint(x: 17.18, y: 9.08),
                   control2: CGPoint(x: 12, y: 3.25))
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
    ctx.addPath(path)
    ctx.strokePath()
  }
}