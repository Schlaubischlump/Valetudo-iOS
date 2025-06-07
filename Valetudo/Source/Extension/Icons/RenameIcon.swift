import CoreGraphics
import UIKit

extension UIImage {
  static func svgRenameicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawRenameicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawRenameicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 17, y: 7))
    path.addLine(to: CGPoint(x: 22, y: 7))
    path.addLine(to: CGPoint(x: 22, y: 17))
    path.addLine(to: CGPoint(x: 17, y: 17))
    path.addLine(to: CGPoint(x: 17, y: 19))
    path.addCurve(to: CGPoint(x: 17.29, y: 19.71),
                   control1: CGPoint(x: 17, y: 19.27),
                   control2: CGPoint(x: 17.11, y: 19.52))
    path.addCurve(to: CGPoint(x: 18, y: 20),
                   control1: CGPoint(x: 17.48, y: 19.89),
                   control2: CGPoint(x: 17.73, y: 20))
    path.addLine(to: CGPoint(x: 20, y: 20))
    path.addLine(to: CGPoint(x: 20, y: 22))
    path.addLine(to: CGPoint(x: 17.5, y: 22))
    path.addCurve(to: CGPoint(x: 16, y: 21),
                   control1: CGPoint(x: 16.95, y: 22),
                   control2: CGPoint(x: 16, y: 21.55))
    path.addCurve(to: CGPoint(x: 14.5, y: 22),
                   control1: CGPoint(x: 16, y: 21.55),
                   control2: CGPoint(x: 15.05, y: 22))
    path.addLine(to: CGPoint(x: 12, y: 22))
    path.addLine(to: CGPoint(x: 12, y: 20))
    path.addLine(to: CGPoint(x: 14, y: 20))
    path.addCurve(to: CGPoint(x: 14.71, y: 19.71),
                   control1: CGPoint(x: 14.27, y: 20),
                   control2: CGPoint(x: 14.52, y: 19.89))
    path.addCurve(to: CGPoint(x: 15, y: 19),
                   control1: CGPoint(x: 14.89, y: 19.52),
                   control2: CGPoint(x: 15, y: 19.27))
    path.addLine(to: CGPoint(x: 15, y: 5))
    path.addCurve(to: CGPoint(x: 14.71, y: 4.29),
                   control1: CGPoint(x: 15, y: 4.73),
                   control2: CGPoint(x: 14.89, y: 4.48))
    path.addCurve(to: CGPoint(x: 14, y: 4),
                   control1: CGPoint(x: 14.52, y: 4.11),
                   control2: CGPoint(x: 14.27, y: 4))
    path.addLine(to: CGPoint(x: 12, y: 4))
    path.addLine(to: CGPoint(x: 12, y: 2))
    path.addLine(to: CGPoint(x: 14.5, y: 2))
    path.addCurve(to: CGPoint(x: 16, y: 3),
                   control1: CGPoint(x: 15.05, y: 2),
                   control2: CGPoint(x: 16, y: 2.45))
    path.addCurve(to: CGPoint(x: 17.5, y: 2),
                   control1: CGPoint(x: 16, y: 2.45),
                   control2: CGPoint(x: 16.95, y: 2))
    path.addLine(to: CGPoint(x: 20, y: 2))
    path.addLine(to: CGPoint(x: 20, y: 4))
    path.addLine(to: CGPoint(x: 18, y: 4))
    path.addCurve(to: CGPoint(x: 17.29, y: 4.29),
                   control1: CGPoint(x: 17.73, y: 4),
                   control2: CGPoint(x: 17.48, y: 4.11))
    path.addCurve(to: CGPoint(x: 17, y: 5),
                   control1: CGPoint(x: 17.11, y: 4.48),
                   control2: CGPoint(x: 17, y: 4.73))
    path.addLine(to: CGPoint(x: 17, y: 7))
    path.move(to: CGPoint(x: 2, y: 7))
    path.addLine(to: CGPoint(x: 13, y: 7))
    path.addLine(to: CGPoint(x: 13, y: 9))
    path.addLine(to: CGPoint(x: 4, y: 9))
    path.addLine(to: CGPoint(x: 4, y: 15))
    path.addLine(to: CGPoint(x: 13, y: 15))
    path.addLine(to: CGPoint(x: 13, y: 17))
    path.addLine(to: CGPoint(x: 2, y: 17))
    path.addLine(to: CGPoint(x: 2, y: 7))
    path.move(to: CGPoint(x: 20, y: 15))
    path.addLine(to: CGPoint(x: 20, y: 9))
    path.addLine(to: CGPoint(x: 17, y: 9))
    path.addLine(to: CGPoint(x: 17, y: 15))
    path.addLine(to: CGPoint(x: 20, y: 15))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}