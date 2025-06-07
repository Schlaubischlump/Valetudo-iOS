import CoreGraphics
import UIKit

extension UIImage {
  static func waterGradeMax(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawWatergrademaxicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawWatergrademaxicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setFillColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 9.16, y: 0))
    path.addLine(to: CGPoint(x: 8.35, y: 0.98))
    path.addCurve(to: CGPoint(x: 4.55, y: 6.15),
                   control1: CGPoint(x: 8.35, y: 0.98),
                   control2: CGPoint(x: 6.45, y: 3.25))
    path.addCurve(to: CGPoint(x: 0.65, y: 15.49),
                   control1: CGPoint(x: 2.65, y: 9.05),
                   control2: CGPoint(x: 0.65, y: 12.49))
    path.addCurve(to: CGPoint(x: 9.16, y: 24),
                   control1: CGPoint(x: 0.65, y: 20.18),
                   control2: CGPoint(x: 4.47, y: 24))
    path.addCurve(to: CGPoint(x: 13.27, y: 22.94),
                   control1: CGPoint(x: 10.65, y: 24),
                   control2: CGPoint(x: 12.05, y: 23.61))
    path.addCurve(to: CGPoint(x: 11.29, y: 18.33),
                   control1: CGPoint(x: 12.05, y: 21.77),
                   control2: CGPoint(x: 11.29, y: 20.13))
    path.addCurve(to: CGPoint(x: 14.01, y: 11.71),
                   control1: CGPoint(x: 11.29, y: 16.01),
                   control2: CGPoint(x: 12.72, y: 13.67))
    path.addCurve(to: CGPoint(x: 15.7, y: 9.32),
                   control1: CGPoint(x: 14.62, y: 10.78),
                   control2: CGPoint(x: 15.22, y: 9.95))
    path.addCurve(to: CGPoint(x: 13.78, y: 6.15),
                   control1: CGPoint(x: 15.1, y: 8.23),
                   control2: CGPoint(x: 14.43, y: 7.16))
    path.addCurve(to: CGPoint(x: 9.98, y: 0.98),
                   control1: CGPoint(x: 11.88, y: 3.25),
                   control2: CGPoint(x: 9.98, y: 0.98))
    path.addLine(to: CGPoint(x: 9.16, y: -0))
    path.closeSubpath()
    path.move(to: CGPoint(x: 17.67, y: 8))
    path.addLine(to: CGPoint(x: 17.13, y: 8.65))
    path.addCurve(to: CGPoint(x: 14.6, y: 12.1),
                   control1: CGPoint(x: 17.13, y: 8.65),
                   control2: CGPoint(x: 15.86, y: 10.16))
    path.addCurve(to: CGPoint(x: 12, y: 18.33),
                   control1: CGPoint(x: 13.33, y: 14.03),
                   control2: CGPoint(x: 12, y: 16.33))
    path.addCurve(to: CGPoint(x: 17.67, y: 24),
                   control1: CGPoint(x: 12, y: 21.45),
                   control2: CGPoint(x: 14.55, y: 24))
    path.addCurve(to: CGPoint(x: 23.35, y: 18.33),
                   control1: CGPoint(x: 20.8, y: 24),
                   control2: CGPoint(x: 23.35, y: 21.45))
    path.addCurve(to: CGPoint(x: 20.75, y: 12.1),
                   control1: CGPoint(x: 23.35, y: 16.33),
                   control2: CGPoint(x: 22.01, y: 14.03))
    path.addCurve(to: CGPoint(x: 18.22, y: 8.65),
                   control1: CGPoint(x: 19.48, y: 10.16),
                   control2: CGPoint(x: 18.22, y: 8.65))
    path.addLine(to: CGPoint(x: 17.67, y: 8))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
  }
}
