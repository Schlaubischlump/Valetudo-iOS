//
//  VTRobotView.swift
//  Valetudo
//
//  Created by David Klopp on 23.04.26.
//
import UIKit

private final class VTRobotVacuumMopView: UIView {
    private let animationKey = "robotMopSpin"

    var fillColor: UIColor = .lightGray.lighter(by: 0.2) {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard rect.width > 0, rect.height > 0 else { return }

        let diameter = min(rect.width, rect.height)
        let circleRect = CGRect(
            x: rect.midX - diameter * 0.5,
            y: rect.midY - diameter * 0.5,
            width: diameter,
            height: diameter
        ).insetBy(dx: diameter * 0.08, dy: diameter * 0.08)

        let padPath = UIBezierPath(ovalIn: circleRect)
        fillColor.setFill()
        padPath.fill()

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        padPath.addClip()

        UIColor.white.withAlphaComponent(0.38).setStroke()
        for index in -2...2 {
            let offset = CGFloat(index) * diameter * 0.16
            let stripePath = UIBezierPath()
            stripePath.move(to: CGPoint(x: circleRect.minX + offset, y: circleRect.maxY))
            stripePath.addCurve(
                to: CGPoint(x: circleRect.maxX + offset, y: circleRect.minY),
                controlPoint1: CGPoint(x: circleRect.midX + offset - diameter * 0.18, y: circleRect.maxY - diameter * 0.18),
                controlPoint2: CGPoint(x: circleRect.midX + offset + diameter * 0.18, y: circleRect.minY + diameter * 0.18)
            )
            stripePath.lineWidth = max(1, diameter * 0.045)
            stripePath.lineCapStyle = .round
            stripePath.stroke()
        }

        context.restoreGState()
    }

    func startAnimating(clockwise: Bool) {
        layer.removeAnimation(forKey: animationKey)

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0
        animation.toValue = (clockwise ? 1 : -1) * 2 * CGFloat.pi
        animation.duration = 0.45
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: animationKey)
    }

    func stopAnimating() {
        layer.removeAnimation(forKey: animationKey)
    }
}

private final class VTRobotVaccuumBrushView: UIView {
    private let animationKey = "robotBrushSpin"

    var lineColor: UIColor = .black {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let size = min(rect.width, rect.height)
        let centerRadius = size * 0.12
        let bristleLength = size * 0.43
        let bristleWidth = max(2, size * 0.1)

        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)

        for index in 0..<3 {
            context.saveGState()
            context.rotate(by: CGFloat(index) * 2 * .pi / 3)

            lineColor.withAlphaComponent(index == 0 ? 1 : 0.55).setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: -centerRadius * 0.45))
            path.addCurve(
                to: CGPoint(x: 0, y: -bristleLength),
                controlPoint1: CGPoint(x: size * 0.09, y: -size * 0.18),
                controlPoint2: CGPoint(x: -size * 0.08, y: -size * 0.32)
            )
            path.lineWidth = bristleWidth
            path.lineCapStyle = .round
            path.stroke()

            context.restoreGState()
        }

        lineColor.setFill()
        UIBezierPath(ovalIn: CGRect(
            x: -centerRadius,
            y: -centerRadius,
            width: centerRadius * 2,
            height: centerRadius * 2
        )).fill()

        UIColor.white.withAlphaComponent(0.7).setFill()
        UIBezierPath(ovalIn: CGRect(
            x: -size * 0.035,
            y: -bristleLength - size * 0.035,
            width: size * 0.07,
            height: size * 0.07
        )).fill()

        context.restoreGState()
    }

    func startAnimating(clockwise: Bool) {
        layer.removeAnimation(forKey: animationKey)

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0
        animation.toValue = (clockwise ? 1 : -1) * 2 * CGFloat.pi
        animation.duration = 0.45
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: animationKey)
    }

    func stopAnimating() {
        layer.removeAnimation(forKey: animationKey)
    }
}

private final class VTRobotVacuumBodyView: UIView {
    var lineColor: UIColor = .black {
        didSet { setNeedsDisplay() }
    }

    var fillColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        isUserInteractionEnabled = false
    }

    override func draw(_ rect: CGRect) {
        guard rect.width > 0, rect.height > 0 else { return }

        let s = min(rect.width, rect.height)
        let drawingRect = CGRect(
            x: rect.midX - s * 0.5,
            y: rect.midY - s * 0.5,
            width: s,
            height: s
        )

        let cx = drawingRect.midX
        let cy = drawingRect.midY

        let outerRadius = s * 0.4
        let middleRadius = s * 0.3
        let lineWidth = s * 0.05
        let centerDotRadius = s * 0.12

        let halfLine = lineWidth * 0.5

        // White regions:
        // 1) annulus between outer and middle circles, excluding the left/right bridge bars
        // 2) inner disk inside the middle circle
        let whitePath = UIBezierPath()
        whitePath.usesEvenOddFillRule = true

        // Annulus outer boundary
        whitePath.append(UIBezierPath(
            arcCenter: CGPoint(x: cx, y: cy),
            radius: outerRadius - halfLine,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ))

        // Annulus inner boundary
        whitePath.append(UIBezierPath(
            arcCenter: CGPoint(x: cx, y: cy),
            radius: middleRadius + halfLine,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ))

        // Remove the black bridge bars from the annulus fill
        let leftBridgeCutout = UIBezierPath(rect: CGRect(
            x: cx - outerRadius,
            y: cy - halfLine,
            width: outerRadius - middleRadius,
            height: lineWidth
        ))
        whitePath.append(leftBridgeCutout)

        let rightBridgeCutout = UIBezierPath(rect: CGRect(
            x: cx + middleRadius,
            y: cy - halfLine,
            width: outerRadius - middleRadius,
            height: lineWidth
        ))
        whitePath.append(rightBridgeCutout)

        // Inner white disk
        whitePath.append(UIBezierPath(
            arcCenter: CGPoint(x: cx, y: cy),
            radius: middleRadius - halfLine,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ))

        fillColor.setFill()
        whitePath.fill()

        // Outer circle stroke
        let outerStroke = UIBezierPath(
            arcCenter: CGPoint(x: cx, y: cy),
            radius: outerRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        outerStroke.lineWidth = lineWidth
        lineColor.setStroke()
        outerStroke.stroke()

        // Middle circle stroke
        let middleStroke = UIBezierPath(
            arcCenter: CGPoint(x: cx, y: cy),
            radius: middleRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        middleStroke.lineWidth = lineWidth
        middleStroke.stroke()

        // Left/right horizontal bridge bars
        let bridges = UIBezierPath()
        bridges.lineWidth = lineWidth
        bridges.lineCapStyle = .butt

        bridges.move(to: CGPoint(x: cx - outerRadius, y: cy))
        bridges.addLine(to: CGPoint(x: cx - middleRadius, y: cy))

        bridges.move(to: CGPoint(x: cx + middleRadius, y: cy))
        bridges.addLine(to: CGPoint(x: cx + outerRadius, y: cy))

        bridges.stroke()

        // Center black dot
        let centerDot = UIBezierPath(
            arcCenter: CGPoint(x: cx, y: cy),
            radius: centerDotRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        lineColor.setFill()
        centerDot.fill()

        // Top pill
        let pillWidth = s * 0.15
        let pillHeight = s * 0.065
        let pillCenterY = cy - s * 0.2
        let pillRect = CGRect(
            x: cx - pillWidth * 0.5,
            y: pillCenterY - pillHeight * 0.5,
            width: pillWidth,
            height: pillHeight
        )
        let pill = UIBezierPath(
            roundedRect: pillRect,
            cornerRadius: pillHeight * 0.5
        )
        pill.fill()
    }
}

final class VTRobotVacuumView: UIView {
    struct Brush: OptionSet {
        let rawValue: Int

        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let left = Brush(rawValue: 1 << 0)
        static let right = Brush(rawValue: 1 << 1)
        static let all: Brush = [.left, .right]
    }
    
    struct MopPad: OptionSet {
        let rawValue: Int

        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let left = MopPad(rawValue: 1 << 0)
        static let right = MopPad(rawValue: 1 << 1)
        static let all: MopPad = [.left, .right]
    }

    private let leftBrushView = VTRobotVaccuumBrushView()
    private let rightBrushView = VTRobotVaccuumBrushView()
    private let leftMopView = VTRobotVacuumMopView()
    private let rightMopView = VTRobotVacuumMopView()
    private let bodyView = VTRobotVacuumBodyView()

    var lineColor: UIColor = .black {
        didSet {
            leftBrushView.lineColor = lineColor
            rightBrushView.lineColor = lineColor
            bodyView.lineColor = lineColor
        }
    }

    var fillColor: UIColor = .white {
        didSet { bodyView.fillColor = fillColor }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bodyView.frame = bounds

        let s = min(bounds.width, bounds.height)
        let drawingRect = CGRect(
            x: bounds.midX - s * 0.5,
            y: bounds.midY - s * 0.5,
            width: s,
            height: s
        )
        let brushDiameter = s * 0.18
        let brushSize = CGSize(width: brushDiameter, height: brushDiameter)
        let mopDiameter = s * 0.3
        let mopSize = CGSize(width: mopDiameter, height: mopDiameter)

        leftBrushView.bounds = CGRect(origin: .zero, size: brushSize)
        rightBrushView.bounds = CGRect(origin: .zero, size: brushSize)
        leftBrushView.center = CGPoint(x: drawingRect.midX - s * 0.235, y: drawingRect.midY + s * 0.365)
        rightBrushView.center = CGPoint(x: drawingRect.midX + s * 0.235, y: drawingRect.midY + s * 0.365)

        leftMopView.bounds = CGRect(origin: .zero, size: mopSize)
        rightMopView.bounds = CGRect(origin: .zero, size: mopSize)
        leftMopView.center = CGPoint(x: mopDiameter, y: drawingRect.minY + mopDiameter/2 * 1.3)
        rightMopView.center = CGPoint(x: drawingRect.maxX - mopDiameter, y: drawingRect.minY + mopDiameter/2 * 1.3)
    }

    private func configureView() {
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false
        contentMode = .redraw

        leftBrushView.lineColor = lineColor
        rightBrushView.lineColor = lineColor
        bodyView.lineColor = lineColor
        bodyView.fillColor = fillColor

        addSubview(leftMopView)
        addSubview(rightMopView)
        addSubview(leftBrushView)
        addSubview(rightBrushView)
        addSubview(bodyView)
    }

    func startAnimatingBrushes(_ brushes: Brush = .all) {
        if brushes.contains(.left) {
            leftBrushView.startAnimating(clockwise: false)
        }
        if brushes.contains(.right) {
            rightBrushView.startAnimating(clockwise: true)
        }
    }
    
    func stopAnimatingBrushes(_ brushes: Brush = .all) {
        if brushes.contains(.left) {
            leftBrushView.stopAnimating()
        }
        if brushes.contains(.right) {
            rightBrushView.stopAnimating()
        }
    }
    
    func startAnimatingMopPads(_ mopPad: MopPad = .all) {
        if mopPad.contains(.left) {
            leftMopView.startAnimating(clockwise: false)
        }
        if mopPad.contains(.right) {
            rightMopView.startAnimating(clockwise: true)
        }
    }

    func stopAnimatingMopPads(_ mopPad: MopPad = .all) {
        if mopPad.contains(.left) {
            leftMopView.stopAnimating()
        }
        if mopPad.contains(.right) {
            rightMopView.stopAnimating()
        }
    }
}
