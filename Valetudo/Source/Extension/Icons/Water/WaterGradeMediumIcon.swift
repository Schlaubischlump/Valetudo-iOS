import CoreGraphics
import UIKit

extension UIImage {
  static func waterGradeMedium(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawWatergrademediumicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawWatergrademediumicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setFillColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 12, y: 0))
    path.addLine(to: CGPoint(x: 11.18, y: 0.98))
    path.addCurve(to: CGPoint(x: 7.39, y: 6.15),
                   control1: CGPoint(x: 11.18, y: 0.98),
                   control2: CGPoint(x: 9.29, y: 3.25))
    path.addCurve(to: CGPoint(x: 3.49, y: 15.49),
                   control1: CGPoint(x: 5.49, y: 9.05),
                   control2: CGPoint(x: 3.49, y: 12.49))
    path.addCurve(to: CGPoint(x: 12, y: 24),
                   control1: CGPoint(x: 3.49, y: 20.18),
                   control2: CGPoint(x: 7.31, y: 24))
    path.addCurve(to: CGPoint(x: 20.51, y: 15.49),
                   control1: CGPoint(x: 16.69, y: 24),
                   control2: CGPoint(x: 20.51, y: 20.18))
    path.addCurve(to: CGPoint(x: 16.61, y: 6.15),
                   control1: CGPoint(x: 20.51, y: 12.49),
                   control2: CGPoint(x: 18.51, y: 9.05))
    path.addCurve(to: CGPoint(x: 12.82, y: 0.98),
                   control1: CGPoint(x: 14.71, y: 3.25),
                   control2: CGPoint(x: 12.82, y: 0.98))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
  }
}
