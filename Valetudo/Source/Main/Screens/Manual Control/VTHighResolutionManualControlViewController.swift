//
//  VTManualControlJoyStickViewController.swift
//  Valetudo
//
//  Created by David Klopp on 04.10.25.
//

// TODO: Complete this

import UIKit

final class VTManualControlJoyStickViewController: VTManualControlViewControllerBase {
    private let baseView = UIView()
    private let knobView = UIView()
    
    private var knobRadius: CGFloat {
        return joystickSize / 4
    }
    private var radius: CGFloat {
        return joystickSize / 2
    }
    
    private let joystickSize: CGFloat = 150
    
    var onMove: ((_ velocity: CGFloat, _ angle: CGFloat) -> Void)?
    
    // MARK: - Lifecycle
    override func setupView() {
        super.setupView()
        
        // Base
        baseView.frame = CGRect(x: 50, y: 300, width: joystickSize, height: joystickSize)
        baseView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        baseView.layer.cornerRadius = joystickSize / 2
        view.addSubview(baseView)
        
        // Knob
        knobView.frame = CGRect(
            x: 0,
            y: 0,
            width: knobRadius * 2,
            height: knobRadius * 2
        )
        knobView.center = baseView.center
        knobView.backgroundColor = UIColor.darkGray
        knobView.layer.cornerRadius = knobRadius
        view.addSubview(knobView)
        
        // Gesture recognizer
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        knobView.addGestureRecognizer(pan)
        knobView.isUserInteractionEnabled = true
    }
    
    override func disableAllButtons() {
        super.disableAllButtons()
    }
    
    // MARK: - Joystick Movement
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let newCenter = CGPoint(
            x: baseView.center.x + translation.x,
            y: baseView.center.y + translation.y
        )
        
        let dx = newCenter.x - baseView.center.x
        let dy = newCenter.y - baseView.center.y
        let distance = sqrt(dx*dx + dy*dy)
        
        if distance <= radius - knobRadius {
            knobView.center = newCenter
        } else {
            // Clamp to circle edge
            let angle = atan2(dy, dx)
            let clampedX = baseView.center.x + cos(angle) * (radius - knobRadius)
            let clampedY = baseView.center.y + sin(angle) * (radius - knobRadius)
            knobView.center = CGPoint(x: clampedX, y: clampedY)
        }
        
        // Normalized vector
        let dxNorm = (knobView.center.x - baseView.center.x) / (radius - knobRadius)
        let dyNorm = (knobView.center.y - baseView.center.y) / (radius - knobRadius)
        
        // Velocity (0 → 1)
        let velocity = min(1, sqrt(dxNorm * dxNorm + dyNorm * dyNorm))
        
        // Angle (-180 → 180)
        let angleRadians = atan2(dyNorm, dxNorm)
        let angleDegrees = angleRadians * 180 / .pi
        
        print("Move", velocity, angleDegrees)
        onMove?(velocity, angleDegrees)
        
        if sender.state == .ended || sender.state == .cancelled {
            resetKnob()
        }
    }
    
    private func resetKnob() {
        UIView.animate(withDuration: 0.2) {
            self.knobView.center = self.baseView.center
        }
        onMove?(0, 0)
    }
}

