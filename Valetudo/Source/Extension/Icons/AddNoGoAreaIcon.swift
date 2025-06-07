import CoreGraphics
import UIKit

extension UIImage {
  static func svgAddnogoareaicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawAddnogoareaicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawAddnogoareaicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 12, y: 2))
    path.addCurve(to: CGPoint(x: 2, y: 12),
                   control1: CGPoint(x: 6.48, y: 2),
                   control2: CGPoint(x: 2, y: 6.48))
    path.addCurve(to: CGPoint(x: 12, y: 22),
                   control1: CGPoint(x: 2, y: 17.52),
                   control2: CGPoint(x: 6.48, y: 22))
    path.addCurve(to: CGPoint(x: 13.74, y: 21.85),
                   control1: CGPoint(x: 12.59, y: 22),
                   control2: CGPoint(x: 13.17, y: 21.95))
    path.addCurve(to: CGPoint(x: 13, y: 19),
                   control1: CGPoint(x: 13.26, y: 20.97),
                   control2: CGPoint(x: 13.01, y: 20))
    path.addCurve(to: CGPoint(x: 16.62, y: 13.5),
                   control1: CGPoint(x: 13, y: 16.61),
                   control2: CGPoint(x: 14.43, y: 14.45))
    path.addLine(to: CGPoint(x: 3.35, y: 13.5))
    path.addLine(to: CGPoint(x: 3.35, y: 10.5))
    path.addLine(to: CGPoint(x: 20.65, y: 10.5))
    path.addLine(to: CGPoint(x: 20.65, y: 13.23))
    path.addCurve(to: CGPoint(x: 21.85, y: 13.72),
                   control1: CGPoint(x: 21.07, y: 13.35),
                   control2: CGPoint(x: 21.47, y: 13.52))
    path.addCurve(to: CGPoint(x: 22, y: 12),
                   control1: CGPoint(x: 21.95, y: 13.16),
                   control2: CGPoint(x: 22, y: 12.59))
    path.addCurve(to: CGPoint(x: 12, y: 2),
                   control1: CGPoint(x: 22, y: 6.48),
                   control2: CGPoint(x: 17.52, y: 2))
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