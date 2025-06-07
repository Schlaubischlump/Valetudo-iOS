import CoreGraphics
import UIKit

extension UIImage {
  static func svgSwaggeruiicon(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
    let f = UIGraphicsImageRendererFormat.preferred()
    f.opaque = false
    let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
    return UIGraphicsImageRenderer(size: size, format: f).image {
      drawSwaggeruiicon(in: $0.cgContext, scale: scale)
    }
  }

  private static func drawSwaggeruiicon(in ctx: CGContext, scale: CGSize) {
    ctx.scaleBy(x: scale.width, y: scale.height)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(2)
    ctx.setMiterLimit(4)
    let rgb = CGColorSpaceCreateDeviceRGB()
    let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
    ctx.setStrokeColor(color1)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 12, y: 1))
    path.addCurve(to: CGPoint(x: 1, y: 12),
                   control1: CGPoint(x: 5.94, y: 1),
                   control2: CGPoint(x: 1, y: 5.93))
    path.addCurve(to: CGPoint(x: 12, y: 23),
                   control1: CGPoint(x: 1, y: 18.07),
                   control2: CGPoint(x: 5.93, y: 23))
    path.addCurve(to: CGPoint(x: 23, y: 12),
                   control1: CGPoint(x: 18.07, y: 23),
                   control2: CGPoint(x: 23, y: 18.07))
    path.addCurve(to: CGPoint(x: 12, y: 1),
                   control1: CGPoint(x: 23, y: 5.94),
                   control2: CGPoint(x: 18.07, y: 1))
    path.closeSubpath()
    path.move(to: CGPoint(x: 12, y: 2.05))
    path.addCurve(to: CGPoint(x: 21.95, y: 12),
                   control1: CGPoint(x: 17.5, y: 2.05),
                   control2: CGPoint(x: 21.95, y: 6.5))
    path.addCurve(to: CGPoint(x: 12, y: 21.95),
                   control1: CGPoint(x: 21.95, y: 17.5),
                   control2: CGPoint(x: 17.5, y: 21.95))
    path.addCurve(to: CGPoint(x: 2.05, y: 12),
                   control1: CGPoint(x: 6.5, y: 21.95),
                   control2: CGPoint(x: 2.05, y: 17.5))
    path.addCurve(to: CGPoint(x: 12, y: 2.05),
                   control1: CGPoint(x: 2.05, y: 6.5),
                   control2: CGPoint(x: 6.5, y: 2.05))
    path.closeSubpath()
    path.move(to: CGPoint(x: 8.68, y: 6.38))
    path.addCurve(to: CGPoint(x: 8.29, y: 6.38),
                   control1: CGPoint(x: 8.54, y: 6.38),
                   control2: CGPoint(x: 8.41, y: 6.38))
    path.addCurve(to: CGPoint(x: 6.7, y: 7.73),
                   control1: CGPoint(x: 7.39, y: 6.43),
                   control2: CGPoint(x: 6.84, y: 6.86))
    path.addCurve(to: CGPoint(x: 6.57, y: 9.58),
                   control1: CGPoint(x: 6.59, y: 8.34),
                   control2: CGPoint(x: 6.61, y: 8.97))
    path.addCurve(to: CGPoint(x: 6.46, y: 10.53),
                   control1: CGPoint(x: 6.55, y: 9.9),
                   control2: CGPoint(x: 6.52, y: 10.22))
    path.addCurve(to: CGPoint(x: 5.53, y: 11.29),
                   control1: CGPoint(x: 6.34, y: 11.09),
                   control2: CGPoint(x: 6.1, y: 11.26))
    path.addCurve(to: CGPoint(x: 5.31, y: 11.33),
                   control1: CGPoint(x: 5.45, y: 11.3),
                   control2: CGPoint(x: 5.38, y: 11.32))
    path.addLine(to: CGPoint(x: 5.31, y: 12.67))
    path.addCurve(to: CGPoint(x: 6.56, y: 14.17),
                   control1: CGPoint(x: 6.34, y: 12.72),
                   control2: CGPoint(x: 6.48, y: 13.09))
    path.addCurve(to: CGPoint(x: 6.57, y: 15.35),
                   control1: CGPoint(x: 6.59, y: 14.56),
                   control2: CGPoint(x: 6.55, y: 14.95))
    path.addCurve(to: CGPoint(x: 6.72, y: 16.45),
                   control1: CGPoint(x: 6.59, y: 15.72),
                   control2: CGPoint(x: 6.64, y: 16.09))
    path.addCurve(to: CGPoint(x: 9.08, y: 17.57),
                   control1: CGPoint(x: 6.96, y: 17.43),
                   control2: CGPoint(x: 7.92, y: 17.76))
    path.addLine(to: CGPoint(x: 9.08, y: 16.39))
    path.addCurve(to: CGPoint(x: 8.57, y: 16.39),
                   control1: CGPoint(x: 8.89, y: 16.39),
                   control2: CGPoint(x: 8.73, y: 16.39))
    path.addCurve(to: CGPoint(x: 7.99, y: 15.9),
                   control1: CGPoint(x: 8.17, y: 16.38),
                   control2: CGPoint(x: 8.03, y: 16.28))
    path.addCurve(to: CGPoint(x: 7.92, y: 14.41),
                   control1: CGPoint(x: 7.94, y: 15.41),
                   control2: CGPoint(x: 7.95, y: 14.91))
    path.addCurve(to: CGPoint(x: 6.86, y: 12.01),
                   control1: CGPoint(x: 7.86, y: 13.49),
                   control2: CGPoint(x: 7.76, y: 12.59))
    path.addCurve(to: CGPoint(x: 7.76, y: 10.72),
                   control1: CGPoint(x: 7.32, y: 11.67),
                   control2: CGPoint(x: 7.66, y: 11.26))
    path.addCurve(to: CGPoint(x: 7.92, y: 9.59),
                   control1: CGPoint(x: 7.84, y: 10.35),
                   control2: CGPoint(x: 7.89, y: 9.97))
    path.addCurve(to: CGPoint(x: 7.93, y: 8.44),
                   control1: CGPoint(x: 7.94, y: 9.21),
                   control2: CGPoint(x: 7.89, y: 8.82))
    path.addLine(to: CGPoint(x: 7.93, y: 8.44))
    path.addCurve(to: CGPoint(x: 8.76, y: 7.61),
                   control1: CGPoint(x: 7.99, y: 7.84),
                   control2: CGPoint(x: 8.02, y: 7.59))
    path.addCurve(to: CGPoint(x: 9.09, y: 7.59),
                   control1: CGPoint(x: 8.87, y: 7.61),
                   control2: CGPoint(x: 8.97, y: 7.59))
    path.addLine(to: CGPoint(x: 9.09, y: 6.38))
    path.addCurve(to: CGPoint(x: 8.68, y: 6.38),
                   control1: CGPoint(x: 8.95, y: 6.38),
                   control2: CGPoint(x: 8.81, y: 6.38))
    path.closeSubpath()
    path.move(to: CGPoint(x: 15.63, y: 6.39))
    path.addCurve(to: CGPoint(x: 14.89, y: 6.44),
                   control1: CGPoint(x: 15.4, y: 6.38),
                   control2: CGPoint(x: 15.15, y: 6.4))
    path.addLine(to: CGPoint(x: 14.89, y: 7.61))
    path.addCurve(to: CGPoint(x: 15.46, y: 7.61),
                   control1: CGPoint(x: 15.11, y: 7.61),
                   control2: CGPoint(x: 15.29, y: 7.61))
    path.addCurve(to: CGPoint(x: 16.02, y: 8.07),
                   control1: CGPoint(x: 15.76, y: 7.62),
                   control2: CGPoint(x: 15.99, y: 7.73))
    path.addCurve(to: CGPoint(x: 16.08, y: 8.99),
                   control1: CGPoint(x: 16.05, y: 8.37),
                   control2: CGPoint(x: 16.05, y: 8.68))
    path.addCurve(to: CGPoint(x: 16.27, y: 10.83),
                   control1: CGPoint(x: 16.14, y: 9.6),
                   control2: CGPoint(x: 16.17, y: 10.22))
    path.addCurve(to: CGPoint(x: 17.14, y: 12),
                   control1: CGPoint(x: 16.37, y: 11.33),
                   control2: CGPoint(x: 16.71, y: 11.7))
    path.addCurve(to: CGPoint(x: 16.13, y: 14.03),
                   control1: CGPoint(x: 16.39, y: 12.51),
                   control2: CGPoint(x: 16.17, y: 13.23))
    path.addCurve(to: CGPoint(x: 16.07, y: 15.71),
                   control1: CGPoint(x: 16.11, y: 14.59),
                   control2: CGPoint(x: 16.1, y: 15.15))
    path.addCurve(to: CGPoint(x: 15.35, y: 16.39),
                   control1: CGPoint(x: 16.04, y: 16.21),
                   control2: CGPoint(x: 15.87, y: 16.38))
    path.addCurve(to: CGPoint(x: 14.91, y: 16.42),
                   control1: CGPoint(x: 15.21, y: 16.4),
                   control2: CGPoint(x: 15.07, y: 16.41))
    path.addLine(to: CGPoint(x: 14.91, y: 17.61))
    path.addCurve(to: CGPoint(x: 15.76, y: 17.61),
                   control1: CGPoint(x: 15.21, y: 17.61),
                   control2: CGPoint(x: 15.49, y: 17.63))
    path.addCurve(to: CGPoint(x: 17.3, y: 16.32),
                   control1: CGPoint(x: 16.61, y: 17.56),
                   control2: CGPoint(x: 17.13, y: 17.15))
    path.addCurve(to: CGPoint(x: 17.43, y: 14.94),
                   control1: CGPoint(x: 17.37, y: 15.86),
                   control2: CGPoint(x: 17.41, y: 15.4))
    path.addCurve(to: CGPoint(x: 17.5, y: 13.67),
                   control1: CGPoint(x: 17.46, y: 14.52),
                   control2: CGPoint(x: 17.45, y: 14.09))
    path.addCurve(to: CGPoint(x: 18.51, y: 12.7),
                   control1: CGPoint(x: 17.56, y: 13.02),
                   control2: CGPoint(x: 17.86, y: 12.75))
    path.addCurve(to: CGPoint(x: 18.7, y: 12.66),
                   control1: CGPoint(x: 18.58, y: 12.69),
                   control2: CGPoint(x: 18.64, y: 12.68))
    path.addLine(to: CGPoint(x: 18.7, y: 11.32))
    path.addCurve(to: CGPoint(x: 18.43, y: 11.29),
                   control1: CGPoint(x: 18.59, y: 11.31),
                   control2: CGPoint(x: 18.51, y: 11.29))
    path.addLine(to: CGPoint(x: 18.43, y: 11.29))
    path.addCurve(to: CGPoint(x: 17.57, y: 10.64),
                   control1: CGPoint(x: 17.94, y: 11.27),
                   control2: CGPoint(x: 17.69, y: 11.1))
    path.addCurve(to: CGPoint(x: 17.43, y: 9.73),
                   control1: CGPoint(x: 17.5, y: 10.34),
                   control2: CGPoint(x: 17.45, y: 10.03))
    path.addCurve(to: CGPoint(x: 17.36, y: 8.02),
                   control1: CGPoint(x: 17.4, y: 9.16),
                   control2: CGPoint(x: 17.4, y: 8.59))
    path.addCurve(to: CGPoint(x: 15.63, y: 6.39),
                   control1: CGPoint(x: 17.29, y: 6.93),
                   control2: CGPoint(x: 16.64, y: 6.42))
    path.closeSubpath()
    path.move(to: CGPoint(x: 14.7, y: 11.23))
    path.addLine(to: CGPoint(x: 14.7, y: 11.23))
    path.addCurve(to: CGPoint(x: 13.9, y: 11.99),
                   control1: CGPoint(x: 14.27, y: 11.22),
                   control2: CGPoint(x: 13.91, y: 11.56))
    path.addCurve(to: CGPoint(x: 14.68, y: 12.77),
                   control1: CGPoint(x: 13.9, y: 12.42),
                   control2: CGPoint(x: 14.25, y: 12.77))
    path.addLine(to: CGPoint(x: 14.69, y: 12.77))
    path.addCurve(to: CGPoint(x: 15.49, y: 12.01),
                   control1: CGPoint(x: 15.07, y: 12.84),
                   control2: CGPoint(x: 15.47, y: 12.46))
    path.addCurve(to: CGPoint(x: 14.7, y: 11.23),
                   control1: CGPoint(x: 15.51, y: 11.59),
                   control2: CGPoint(x: 15.13, y: 11.23))
    path.closeSubpath()
    path.move(to: CGPoint(x: 9.32, y: 11.23))
    path.addCurve(to: CGPoint(x: 8.51, y: 11.96),
                   control1: CGPoint(x: 8.9, y: 11.21),
                   control2: CGPoint(x: 8.53, y: 11.53))
    path.addCurve(to: CGPoint(x: 9.24, y: 12.77),
                   control1: CGPoint(x: 8.49, y: 12.39),
                   control2: CGPoint(x: 8.82, y: 12.75))
    path.addLine(to: CGPoint(x: 9.29, y: 12.77))
    path.addCurve(to: CGPoint(x: 10.1, y: 12.06),
                   control1: CGPoint(x: 9.71, y: 12.8),
                   control2: CGPoint(x: 10.07, y: 12.48))
    path.addLine(to: CGPoint(x: 10.1, y: 12.01))
    path.addCurve(to: CGPoint(x: 9.34, y: 11.23),
                   control1: CGPoint(x: 10.1, y: 11.59),
                   control2: CGPoint(x: 9.76, y: 11.24))
    path.closeSubpath()
    path.move(to: CGPoint(x: 11.99, y: 11.23))
    path.addCurve(to: CGPoint(x: 11.22, y: 11.94),
                   control1: CGPoint(x: 11.58, y: 11.21),
                   control2: CGPoint(x: 11.24, y: 11.53))
    path.addCurve(to: CGPoint(x: 11.23, y: 12.01),
                   control1: CGPoint(x: 11.22, y: 11.97),
                   control2: CGPoint(x: 11.22, y: 11.99))
    path.addCurve(to: CGPoint(x: 12.01, y: 12.77),
                   control1: CGPoint(x: 11.23, y: 12.47),
                   control2: CGPoint(x: 11.54, y: 12.77))
    path.addCurve(to: CGPoint(x: 12.77, y: 11.99),
                   control1: CGPoint(x: 12.48, y: 12.77),
                   control2: CGPoint(x: 12.77, y: 12.47))
    path.addCurve(to: CGPoint(x: 11.99, y: 11.23),
                   control1: CGPoint(x: 12.77, y: 11.53),
                   control2: CGPoint(x: 12.46, y: 11.22))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.strokePath()
  }
}