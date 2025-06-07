import CoreGraphics
import UIKit

extension UIImage {
  static func waterGradeLow(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawWatergradelowicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawWatergradelowicon(in ctx: CGContext, scale: CGSize) {
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
    path.addLine(to: CGPoint(x: 12.82, y: 0.98))
    path.addCurve(to: CGPoint(x: 16.61, y: 6.15),
                   control1: CGPoint(x: 12.82, y: 0.98),
                   control2: CGPoint(x: 14.71, y: 3.25))
    path.addCurve(to: CGPoint(x: 19.62, y: 11.58),
                   control1: CGPoint(x: 17.72, y: 7.84),
                   control2: CGPoint(x: 18.86, y: 9.71))
    path.addCurve(to: CGPoint(x: 20.51, y: 15.49),
                   control1: CGPoint(x: 20.16, y: 12.91),
                   control2: CGPoint(x: 20.51, y: 14.24))
    path.addCurve(to: CGPoint(x: 12, y: 24),
                   control1: CGPoint(x: 20.51, y: 20.18),
                   control2: CGPoint(x: 16.69, y: 24))
    path.addCurve(to: CGPoint(x: 3.49, y: 15.49),
                   control1: CGPoint(x: 7.31, y: 24),
                   control2: CGPoint(x: 3.49, y: 20.18))
    path.addCurve(to: CGPoint(x: 7.39, y: 6.15),
                   control1: CGPoint(x: 3.49, y: 12.49),
                   control2: CGPoint(x: 5.49, y: 9.05))
    path.addCurve(to: CGPoint(x: 11.18, y: 0.98),
                   control1: CGPoint(x: 9.29, y: 3.25),
                   control2: CGPoint(x: 11.18, y: 0.98))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12, y: 3.45))
    path.addCurve(to: CGPoint(x: 9.16, y: 7.31),
                   control1: CGPoint(x: 11.44, y: 4.15),
                   control2: CGPoint(x: 10.58, y: 5.15))
    path.addCurve(to: CGPoint(x: 7.72, y: 9.73),
                   control1: CGPoint(x: 8.66, y: 8.08),
                   control2: CGPoint(x: 8.17, y: 8.9))
    path.addCurve(to: CGPoint(x: 9.09, y: 9.45),
                   control1: CGPoint(x: 8.16, y: 9.55),
                   control2: CGPoint(x: 8.62, y: 9.45))
    path.addCurve(to: CGPoint(x: 11.79, y: 10.25),
                   control1: CGPoint(x: 9.94, y: 9.44),
                   control2: CGPoint(x: 10.84, y: 9.7))
    path.addCurve(to: CGPoint(x: 14.6, y: 12.33),
                   control1: CGPoint(x: 12.55, y: 10.69),
                   control2: CGPoint(x: 13.17, y: 11.15))
    path.addCurve(to: CGPoint(x: 15.67, y: 13.2),
                   control1: CGPoint(x: 15.25, y: 12.88),
                   control2: CGPoint(x: 15.38, y: 12.98))
    path.addCurve(to: CGPoint(x: 17.63, y: 14.32),
                   control1: CGPoint(x: 16.53, y: 13.88),
                   control2: CGPoint(x: 17.12, y: 14.21))
    path.addCurve(to: CGPoint(x: 18.07, y: 14.35),
                   control1: CGPoint(x: 17.72, y: 14.34),
                   control2: CGPoint(x: 17.99, y: 14.36))
    path.addCurve(to: CGPoint(x: 18.22, y: 14.31),
                   control1: CGPoint(x: 18.12, y: 14.34),
                   control2: CGPoint(x: 18.17, y: 14.32))
    path.addCurve(to: CGPoint(x: 14.83, y: 7.31),
                   control1: CGPoint(x: 17.75, y: 12.34),
                   control2: CGPoint(x: 16.33, y: 9.6))
    path.addCurve(to: CGPoint(x: 12, y: 3.45),
                   control1: CGPoint(x: 13.42, y: 5.15),
                   control2: CGPoint(x: 12.56, y: 4.15))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
  }
}
