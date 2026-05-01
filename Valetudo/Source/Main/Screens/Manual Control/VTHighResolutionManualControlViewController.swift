//
//  VTManualControlJoyStickViewController.swift
//  Valetudo
//
//  Created by David Klopp on 04.10.25.
//
import UIKit

final class VTHighResolutionManualControlViewController: VTManualControlViewControllerBase {
    private enum InputStateType { case start, move, stop }

    private let baseView = UIView()
    private let knobView = UIView()

    private var knobCenterXConstraint: NSLayoutConstraint!
    private var knobCenterYConstraint: NSLayoutConstraint!

    private let joystickSize: CGFloat = 150
    private var knobRadius: CGFloat {
        joystickSize / 4
    }

    private var radius: CGFloat {
        joystickSize / 2
    }

    private var currentVelocity: CGFloat = 0
    private var currentAngle: CGFloat = 0
    private var moveTimer: Timer?

    override func setupView() {
        super.setupView()

        setupJoystickConstraints()
        setupGesture()
    }

    // MARK: - Setup

    private func setupJoystickConstraints() {
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        baseView.layer.cornerRadius = joystickSize / 2
        view.addSubview(baseView)

        NSLayoutConstraint.activate([
            baseView.widthAnchor.constraint(equalToConstant: joystickSize),
            baseView.heightAnchor.constraint(equalTo: baseView.widthAnchor),
            baseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            baseView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        knobView.translatesAutoresizingMaskIntoConstraints = false
        knobView.backgroundColor = UIColor.darkGray
        knobView.layer.cornerRadius = knobRadius
        // knobView is never interactive. The gesture is set on the baseView.
        knobView.isUserInteractionEnabled = false
        view.addSubview(knobView)

        let knobWidth = knobView.widthAnchor.constraint(equalToConstant: knobRadius * 2)
        let knobHeight = knobView.heightAnchor.constraint(equalTo: knobView.widthAnchor)
        knobCenterXConstraint = knobView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor, constant: 0)
        knobCenterYConstraint = knobView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: 0)

        NSLayoutConstraint.activate([knobWidth, knobHeight, knobCenterXConstraint, knobCenterYConstraint])
    }

    override func disableAllButtons() {
        disableJoyStick()
        super.disableAllButtons()
    }

    private func enableJoyStick() {
        knobView.backgroundColor = UIColor.tintColor
        baseView.isUserInteractionEnabled = true
    }

    private func disableJoyStick() {
        knobView.backgroundColor = UIColor.darkGray
        baseView.isUserInteractionEnabled = false
    }

    override func reconnectAndRefresh() async {
        let isEnabled = await (try? client.getHighResolutionManualControlIsEnabled()) ?? false
        if isEnabled {
            enableJoyStick()
        }
        finalizeLoading(manualControlIsEnabled: isEnabled)
    }

    // MARK: - Pan Gesture

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        baseView.addGestureRecognizer(pan)
    }

    private func resetKnob() {
        knobCenterXConstraint.constant = 0
        knobCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: baseView)
        let centerPoint = CGPoint(x: baseView.bounds.midX, y: baseView.bounds.midY)

        var dx = location.x - centerPoint.x
        var dy = location.y - centerPoint.y

        let limit = radius
        dx = max(-limit, min(limit, dx))
        dy = max(-limit, min(limit, dy))

        // move the knob
        knobCenterXConstraint.constant = dx
        knobCenterYConstraint.constant = dy

        let normalizedX = dx / limit
        let normalizedY = -dy / limit

        // velocity maps directly to Y, angle maps to X * 120
        let velocity = max(min(1.0, normalizedY), -1.0)
        let angle = max(min(120.0, normalizedX * 120.0), -120.0)

        currentVelocity = velocity
        currentAngle = angle

        switch sender.state {
        case .began:
            handleInputStateUpdate(type: .start)
        case .changed:
            handleInputStateUpdate(type: .move)
        case .ended, .cancelled, .failed:
            handleInputStateUpdate(type: .stop)
            resetKnob()
        default:
            break
        }
    }

    private func handleInputStateUpdate(type: InputStateType) {
        switch type {
        case .stop:
            // Stop repeating updates, send immediate zero state
            moveTimer?.invalidate()
            moveTimer = nil
            Task {
                try? await client.highResolutionManualControlMove(angle: 0, velocity: 0)
            }

        case .start:
            // Send first sample immediately and begin repeating
            sendMoveCommand()
            startMoveEventLoop()

        case .move:
            // If not already repeating, start
            if moveTimer == nil {
                sendMoveCommand()
                startMoveEventLoop()
            }
            // If timer already running, the timer will continue to publish current values.
        }
    }

    // MARK: - Actions

    override func enableManualControl() async throws {
        try await client.enableHighResolutionManualControl()
    }

    override func disableManualControl() async throws {
        try await client.disableHighResolutionManualControl()
    }

    private func sendMoveCommand() {
        Task {
            try? await client.highResolutionManualControlMove(angle: currentAngle, velocity: currentVelocity)
        }
    }

    private func startMoveEventLoop() {
        // only fire events every 250ms
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            let capturedSelf = self
            Task { @MainActor in
                capturedSelf?.sendMoveCommand()
            }
        }
    }
}
