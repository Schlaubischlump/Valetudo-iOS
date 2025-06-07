import CoreGraphics
import UIKit

extension UIImage {
  static func fanSpeedMax(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawFanspeedmaxicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawFanspeedmaxicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setFillColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 9.18, y: 0.01))
    path.addCurve(to: CGPoint(x: 8.86, y: 0.02),
                   control1: CGPoint(x: 9.07, y: -0),
                   control2: CGPoint(x: 8.96, y: -0))
    path.addCurve(to: CGPoint(x: 8.06, y: 0.51),
                   control1: CGPoint(x: 8.54, y: 0.07),
                   control2: CGPoint(x: 8.25, y: 0.25))
    path.addCurve(to: CGPoint(x: 5.01, y: 8.81),
                   control1: CGPoint(x: 6.05, y: 3.32),
                   control2: CGPoint(x: 4.98, y: 6.09))
    path.addCurve(to: CGPoint(x: 6.25, y: 10.02),
                   control1: CGPoint(x: 5.02, y: 9.49),
                   control2: CGPoint(x: 5.57, y: 10.03))
    path.addCurve(to: CGPoint(x: 7.46, y: 8.78),
                   control1: CGPoint(x: 6.93, y: 10.02),
                   control2: CGPoint(x: 7.47, y: 9.46))
    path.addCurve(to: CGPoint(x: 10.06, y: 1.94),
                   control1: CGPoint(x: 7.44, y: 6.73),
                   control2: CGPoint(x: 8.25, y: 4.46))
    path.addCurve(to: CGPoint(x: 9.77, y: 0.23),
                   control1: CGPoint(x: 10.45, y: 1.39),
                   control2: CGPoint(x: 10.32, y: 0.62))
    path.addCurve(to: CGPoint(x: 9.18, y: 0.01),
                   control1: CGPoint(x: 9.6, y: 0.1),
                   control2: CGPoint(x: 9.39, y: 0.03))
    path.closeSubpath()
    path.move(to: CGPoint(x: 18.33, y: 2.18))
    path.addCurve(to: CGPoint(x: 9.94, y: 4.97),
                   control1: CGPoint(x: 14.89, y: 2.36),
                   control2: CGPoint(x: 12.05, y: 3.25))
    path.addCurve(to: CGPoint(x: 9.5, y: 5.79),
                   control1: CGPoint(x: 9.69, y: 5.17),
                   control2: CGPoint(x: 9.53, y: 5.47))
    path.addCurve(to: CGPoint(x: 9.77, y: 6.69),
                   control1: CGPoint(x: 9.46, y: 6.12),
                   control2: CGPoint(x: 9.56, y: 6.44))
    path.addCurve(to: CGPoint(x: 11.49, y: 6.87),
                   control1: CGPoint(x: 10.19, y: 7.22),
                   control2: CGPoint(x: 10.97, y: 7.3))
    path.addCurve(to: CGPoint(x: 18.46, y: 4.63),
                   control1: CGPoint(x: 13.08, y: 5.57),
                   control2: CGPoint(x: 15.36, y: 4.79))
    path.addCurve(to: CGPoint(x: 19.31, y: 4.23),
                   control1: CGPoint(x: 18.78, y: 4.61),
                   control2: CGPoint(x: 19.09, y: 4.47))
    path.addCurve(to: CGPoint(x: 19.62, y: 3.34),
                   control1: CGPoint(x: 19.53, y: 3.99),
                   control2: CGPoint(x: 19.64, y: 3.67))
    path.addCurve(to: CGPoint(x: 19.22, y: 2.49),
                   control1: CGPoint(x: 19.61, y: 3.02),
                   control2: CGPoint(x: 19.46, y: 2.71))
    path.addCurve(to: CGPoint(x: 18.33, y: 2.18),
                   control1: CGPoint(x: 18.98, y: 2.27),
                   control2: CGPoint(x: 18.66, y: 2.16))
    path.closeSubpath()
    path.move(to: CGPoint(x: 1.51, y: 5.94))
    path.addCurve(to: CGPoint(x: 1.2, y: 5.99),
                   control1: CGPoint(x: 1.41, y: 5.94),
                   control2: CGPoint(x: 1.3, y: 5.96))
    path.addCurve(to: CGPoint(x: 0.35, y: 7.5),
                   control1: CGPoint(x: 0.54, y: 6.17),
                   control2: CGPoint(x: 0.17, y: 6.85))
    path.addCurve(to: CGPoint(x: 4.93, y: 15.06),
                   control1: CGPoint(x: 1.29, y: 10.82),
                   control2: CGPoint(x: 2.79, y: 13.39))
    path.addCurve(to: CGPoint(x: 5.84, y: 15.31),
                   control1: CGPoint(x: 5.19, y: 15.26),
                   control2: CGPoint(x: 5.52, y: 15.35))
    path.addCurve(to: CGPoint(x: 6.66, y: 14.85),
                   control1: CGPoint(x: 6.16, y: 15.28),
                   control2: CGPoint(x: 6.46, y: 15.11))
    path.addCurve(to: CGPoint(x: 6.45, y: 13.13),
                   control1: CGPoint(x: 7.07, y: 14.32),
                   control2: CGPoint(x: 6.98, y: 13.55))
    path.addCurve(to: CGPoint(x: 2.71, y: 6.83),
                   control1: CGPoint(x: 4.83, y: 11.86),
                   control2: CGPoint(x: 3.56, y: 9.82))
    path.addCurve(to: CGPoint(x: 1.51, y: 5.94),
                   control1: CGPoint(x: 2.56, y: 6.3),
                   control2: CGPoint(x: 2.07, y: 5.93))
    path.closeSubpath()
    path.move(to: CGPoint(x: 15.7, y: 6.4))
    path.addCurve(to: CGPoint(x: 14.56, y: 7.37),
                   control1: CGPoint(x: 15.15, y: 6.43),
                   control2: CGPoint(x: 14.68, y: 6.82))
    path.addCurve(to: CGPoint(x: 15.5, y: 8.83),
                   control1: CGPoint(x: 14.42, y: 8.03),
                   control2: CGPoint(x: 14.84, y: 8.68))
    path.addCurve(to: CGPoint(x: 21.59, y: 12.88),
                   control1: CGPoint(x: 17.51, y: 9.26),
                   control2: CGPoint(x: 19.54, y: 10.56))
    path.addCurve(to: CGPoint(x: 23.33, y: 12.98),
                   control1: CGPoint(x: 22.04, y: 13.39),
                   control2: CGPoint(x: 22.82, y: 13.43))
    path.addCurve(to: CGPoint(x: 23.74, y: 12.14),
                   control1: CGPoint(x: 23.57, y: 12.77),
                   control2: CGPoint(x: 23.72, y: 12.46))
    path.addCurve(to: CGPoint(x: 23.43, y: 11.25),
                   control1: CGPoint(x: 23.76, y: 11.81),
                   control2: CGPoint(x: 23.65, y: 11.49))
    path.addCurve(to: CGPoint(x: 16.02, y: 6.43),
                   control1: CGPoint(x: 21.14, y: 8.67),
                   control2: CGPoint(x: 18.68, y: 7.01))
    path.addCurve(to: CGPoint(x: 15.7, y: 6.4),
                   control1: CGPoint(x: 15.92, y: 6.41),
                   control2: CGPoint(x: 15.81, y: 6.4))
    path.closeSubpath()
    path.move(to: CGPoint(x: 17.65, y: 11.41))
    path.addCurve(to: CGPoint(x: 17.03, y: 11.54),
                   control1: CGPoint(x: 17.43, y: 11.4),
                   control2: CGPoint(x: 17.22, y: 11.44))
    path.addCurve(to: CGPoint(x: 16.47, y: 13.18),
                   control1: CGPoint(x: 16.42, y: 11.84),
                   control2: CGPoint(x: 16.17, y: 12.57))
    path.addCurve(to: CGPoint(x: 17.1, y: 20.47),
                   control1: CGPoint(x: 17.38, y: 15.02),
                   control2: CGPoint(x: 17.63, y: 17.42))
    path.addCurve(to: CGPoint(x: 18.1, y: 21.89),
                   control1: CGPoint(x: 16.99, y: 21.14),
                   control2: CGPoint(x: 17.43, y: 21.78))
    path.addCurve(to: CGPoint(x: 19.02, y: 21.69),
                   control1: CGPoint(x: 18.42, y: 21.95),
                   control2: CGPoint(x: 18.75, y: 21.88))
    path.addCurve(to: CGPoint(x: 19.52, y: 20.89),
                   control1: CGPoint(x: 19.28, y: 21.5),
                   control2: CGPoint(x: 19.47, y: 21.22))
    path.addCurve(to: CGPoint(x: 18.67, y: 12.09),
                   control1: CGPoint(x: 20.11, y: 17.5),
                   control2: CGPoint(x: 19.87, y: 14.53))
    path.addCurve(to: CGPoint(x: 17.96, y: 11.48),
                   control1: CGPoint(x: 18.53, y: 11.8),
                   control2: CGPoint(x: 18.27, y: 11.58))
    path.addCurve(to: CGPoint(x: 17.65, y: 11.41),
                   control1: CGPoint(x: 17.86, y: 11.44),
                   control2: CGPoint(x: 17.76, y: 11.42))
    path.closeSubpath()
    path.move(to: CGPoint(x: 1.33, y: 15.54))
    path.addCurve(to: CGPoint(x: 0.35, y: 16.28),
                   control1: CGPoint(x: 0.9, y: 15.6),
                   control2: CGPoint(x: 0.52, y: 15.88))
    path.addCurve(to: CGPoint(x: 0.35, y: 17.22),
                   control1: CGPoint(x: 0.23, y: 16.58),
                   control2: CGPoint(x: 0.22, y: 16.92))
    path.addCurve(to: CGPoint(x: 1.01, y: 17.89),
                   control1: CGPoint(x: 0.47, y: 17.52),
                   control2: CGPoint(x: 0.71, y: 17.76))
    path.addCurve(to: CGPoint(x: 9.78, y: 19.02),
                   control1: CGPoint(x: 4.19, y: 19.22),
                   control2: CGPoint(x: 7.14, y: 19.65))
    path.addCurve(to: CGPoint(x: 10.69, y: 17.54),
                   control1: CGPoint(x: 10.44, y: 18.86),
                   control2: CGPoint(x: 10.84, y: 18.2))
    path.addCurve(to: CGPoint(x: 10.14, y: 16.78),
                   control1: CGPoint(x: 10.61, y: 17.22),
                   control2: CGPoint(x: 10.41, y: 16.95))
    path.addCurve(to: CGPoint(x: 9.21, y: 16.63),
                   control1: CGPoint(x: 9.86, y: 16.61),
                   control2: CGPoint(x: 9.52, y: 16.55))
    path.addCurve(to: CGPoint(x: 1.96, y: 15.63),
                   control1: CGPoint(x: 7.21, y: 17.11),
                   control2: CGPoint(x: 4.82, y: 16.82))
    path.addCurve(to: CGPoint(x: 1.33, y: 15.54),
                   control1: CGPoint(x: 1.76, y: 15.54),
                   control2: CGPoint(x: 1.54, y: 15.51))
    path.closeSubpath()
    path.move(to: CGPoint(x: 14.68, y: 15.95))
    path.addCurve(to: CGPoint(x: 13.67, y: 16.66),
                   control1: CGPoint(x: 14.24, y: 15.99),
                   control2: CGPoint(x: 13.86, y: 16.26))
    path.addCurve(to: CGPoint(x: 8.36, y: 21.7),
                   control1: CGPoint(x: 12.8, y: 18.51),
                   control2: CGPoint(x: 11.08, y: 20.21))
    path.addCurve(to: CGPoint(x: 7.88, y: 23.36),
                   control1: CGPoint(x: 7.77, y: 22.02),
                   control2: CGPoint(x: 7.55, y: 22.77))
    path.addCurve(to: CGPoint(x: 9.54, y: 23.85),
                   control1: CGPoint(x: 8.2, y: 23.96),
                   control2: CGPoint(x: 8.95, y: 24.17))
    path.addCurve(to: CGPoint(x: 15.89, y: 17.7),
                   control1: CGPoint(x: 12.57, y: 22.19),
                   control2: CGPoint(x: 14.74, y: 20.16))
    path.addCurve(to: CGPoint(x: 15.93, y: 16.76),
                   control1: CGPoint(x: 16.03, y: 17.4),
                   control2: CGPoint(x: 16.05, y: 17.07))
    path.addCurve(to: CGPoint(x: 15.3, y: 16.07),
                   control1: CGPoint(x: 15.82, y: 16.45),
                   control2: CGPoint(x: 15.6, y: 16.2))
    path.addCurve(to: CGPoint(x: 14.68, y: 15.95),
                   control1: CGPoint(x: 15.11, y: 15.97),
                   control2: CGPoint(x: 14.89, y: 15.94))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
  }
}
