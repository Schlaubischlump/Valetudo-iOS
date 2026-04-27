import CoreGraphics
import UIKit

extension UIImage {
    static func waterGradeMin(size: CGSize = CGSize(width: 24.0, height: 24.0)) -> UIImage {
        let f = UIGraphicsImageRendererFormat.preferred()
        f.opaque = false
        let scale = CGSize(width: size.width / 24.0, height: size.height / 24.0)
        return UIGraphicsImageRenderer(size: size, format: f).image {
            drawWatergrademinicon(in: $0.cgContext, scale: scale)
        }
    }

    private static func drawWatergrademinicon(in ctx: CGContext, scale: CGSize) {
        ctx.scaleBy(x: scale.width, y: scale.height)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(2)
        ctx.setMiterLimit(4)
        let rgb = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColor(colorSpace: rgb, components: [0, 0, 0, 1])!
        ctx.setFillColor(color1)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 12, y: -0))
        path.addLine(to: CGPoint(x: 12.82, y: 0.98))
        path.addCurve(to: CGPoint(x: 16.61, y: 6.15),
                      control1: CGPoint(x: 12.82, y: 0.98),
                      control2: CGPoint(x: 14.71, y: 3.25))
        path.addCurve(to: CGPoint(x: 20.51, y: 15.49),
                      control1: CGPoint(x: 18.51, y: 9.05),
                      control2: CGPoint(x: 20.51, y: 12.49))
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
        path.addCurve(to: CGPoint(x: 5.93, y: 13.74),
                      control1: CGPoint(x: 7.81, y: 9.38),
                      control2: CGPoint(x: 6.51, y: 11.83))
        path.addCurve(to: CGPoint(x: 5.96, y: 13.71),
                      control1: CGPoint(x: 5.94, y: 13.73),
                      control2: CGPoint(x: 5.95, y: 13.72))
        path.addCurve(to: CGPoint(x: 8.34, y: 12.86),
                      control1: CGPoint(x: 6.7, y: 13.15),
                      control2: CGPoint(x: 7.5, y: 12.86))
        path.addCurve(to: CGPoint(x: 11.04, y: 13.66),
                      control1: CGPoint(x: 9.19, y: 12.85),
                      control2: CGPoint(x: 10.09, y: 13.11))
        path.addCurve(to: CGPoint(x: 13.85, y: 15.74),
                      control1: CGPoint(x: 11.8, y: 14.1),
                      control2: CGPoint(x: 12.42, y: 14.56))
        path.addCurve(to: CGPoint(x: 14.92, y: 16.61),
                      control1: CGPoint(x: 14.5, y: 16.28),
                      control2: CGPoint(x: 14.63, y: 16.38))
        path.addCurve(to: CGPoint(x: 16.88, y: 17.73),
                      control1: CGPoint(x: 15.78, y: 17.28),
                      control2: CGPoint(x: 16.37, y: 17.62))
        path.addCurve(to: CGPoint(x: 17.32, y: 17.75),
                      control1: CGPoint(x: 16.97, y: 17.75),
                      control2: CGPoint(x: 17.24, y: 17.77))
        path.addCurve(to: CGPoint(x: 18.01, y: 17.64),
                      control1: CGPoint(x: 17.44, y: 17.73),
                      control2: CGPoint(x: 17.74, y: 17.69))
        path.addCurve(to: CGPoint(x: 18.38, y: 15.49),
                      control1: CGPoint(x: 18.25, y: 16.97),
                      control2: CGPoint(x: 18.38, y: 16.24))
        path.addCurve(to: CGPoint(x: 14.83, y: 7.31),
                      control1: CGPoint(x: 18.38, y: 13.57),
                      control2: CGPoint(x: 16.66, y: 10.1))
        path.addCurve(to: CGPoint(x: 12, y: 3.45),
                      control1: CGPoint(x: 13.42, y: 5.15),
                      control2: CGPoint(x: 12.56, y: 4.15))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
    }
}
