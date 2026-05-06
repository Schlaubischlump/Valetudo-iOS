//
//  VTEntityType + Drawing.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import CoreGraphics
import Foundation

extension VTEntityType {
    /// specify drawing order. Lower numbers are drawn on top, larger numbers on bottom.
    var order: Int {
        switch self {
        case .virtual_wall: 0
        case .active_zone: 1
        case .no_go_area: 2
        case .no_mop_area: 3
        case .robot_position: 4
        case .charger_location: 5
        case .obstacle: 6
        case .go_to_target: 7
        case .path: 8
        case .predicted_path: 9
        case .carpet: 10
        }
    }

    var color: CGColor? {
        switch self {
        case .charger_location: .blue
        case .robot_position: .white
        case .active_zone: .white.copy(alpha: 0.18)
        case .path, .predicted_path: nil
        case .carpet: nil
        case .obstacle: .yellow
        default: .black
        }
    }

    var borderColor: CGColor? {
        switch self {
        case .charger_location: .white
        case .robot_position: .lightGray
        case .active_zone: .white
        case .path, .predicted_path: .white
        case .carpet: .lightGray.copy(alpha: 0.5)
        case .obstacle: .lightGray.copy(alpha: 0.9)
        default: .black
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .charger_location: 1.0
        case .robot_position: 0.5
        case .active_zone: 2.0
        case .path, .predicted_path: 0.5
        case .carpet: 0.5
        default: 1.0
        }
    }

    func icon(center: CGPoint) -> CGPath? {
        switch self {
        case .path, .predicted_path: return nil
        case .charger_location:
            let radius = 6.0
            let iconPath = CGMutablePath()
            iconPath.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)

            let boltWidth = radius - 3
            let boltHeight = radius - 2
            let startX = center.x - boltWidth / 2
            let startY = center.y - boltHeight / 2

            iconPath.move(to: CGPoint(x: startX + 0, y: startY + boltHeight * 0.6))
            iconPath.addLine(to: CGPoint(x: startX + boltWidth * 0.4, y: startY + boltHeight * 0.6))
            iconPath.addLine(to: CGPoint(x: startX + boltWidth * 0.2, y: startY + boltHeight))
            iconPath.addLine(to: CGPoint(x: startX + boltWidth, y: startY + boltHeight * 0.4))
            iconPath.addLine(to: CGPoint(x: startX + boltWidth * 0.6, y: startY + boltHeight * 0.4))
            iconPath.addLine(to: CGPoint(x: startX + boltWidth * 0.8, y: startY))
            iconPath.closeSubpath()

            return iconPath
        case .robot_position:
            let radius = 5.0
            let iconPath = CGMutablePath()

            let verticalOffset = radius * 0.25
            let innerCircleRadius = radius * 0.4
            let innerCircleFrame = CGRect(
                x: center.x - innerCircleRadius,
                y: center.y - verticalOffset - innerCircleRadius,
                width: innerCircleRadius * 2,
                height: innerCircleRadius * 2
            )

            // 1. Outer circle
            iconPath.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)

            // 2. Horizontal line (split left and right of center circle)
            iconPath.move(to: CGPoint(x: innerCircleFrame.midX - radius, y: innerCircleFrame.midY))
            iconPath.addLine(to: CGPoint(x: innerCircleFrame.minX, y: innerCircleFrame.midY))

            iconPath.move(to: CGPoint(x: innerCircleFrame.maxX, y: innerCircleFrame.midY))
            iconPath.addLine(to: CGPoint(x: innerCircleFrame.midX + radius, y: innerCircleFrame.midY))

            // 3. Inner center circle
            iconPath.addEllipse(in: innerCircleFrame)

            return iconPath
        case .go_to_target:
            let iconPath = CGMutablePath()

            let headRadius = 4.5
            let headCenter = CGPoint(x: center.x, y: center.y - 7.0)
            iconPath.addArc(center: headCenter, radius: headRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)

            iconPath.move(to: CGPoint(x: headCenter.x - headRadius * 0.75, y: headCenter.y + headRadius * 0.5))
            iconPath.addQuadCurve(
                to: center,
                control: CGPoint(x: headCenter.x - 1.5, y: center.y - 2.0)
            )
            iconPath.addQuadCurve(
                to: CGPoint(x: headCenter.x + headRadius * 0.75, y: headCenter.y + headRadius * 0.5),
                control: CGPoint(x: headCenter.x + 1.5, y: center.y - 2.0)
            )

            let innerRadius = 1.5
            iconPath.addEllipse(in: CGRect(
                x: headCenter.x - innerRadius,
                y: headCenter.y - innerRadius,
                width: innerRadius * 2,
                height: innerRadius * 2
            ))
            return iconPath
        case .carpet: return nil
        case .no_go_area: return nil
        case .no_mop_area: return nil
        case .virtual_wall: return nil
        default: return nil
        }
    }
}
