//
//  VTOverlayKeyboardController.swift
//  Valetudo
//
//  Created by David Klopp on 12.10.25.
//

import UIKit

@MainActor
final class VTOverlayKeyboardController {
    private enum Direction: Hashable {
        case up
        case down
        case left
        case right

        var delta: CGPoint {
            switch self {
            case .up:
                CGPoint(x: 0, y: -VTOverlayKeyboardController.step)
            case .down:
                CGPoint(x: 0, y: VTOverlayKeyboardController.step)
            case .left:
                CGPoint(x: -VTOverlayKeyboardController.step, y: 0)
            case .right:
                CGPoint(x: VTOverlayKeyboardController.step, y: 0)
            }
        }
    }

    private static let step: CGFloat = 5.0
    private static let repeatInitialDelay: UInt64 = 250_000_000
    private static let repeatInterval: UInt64 = 40_000_000

    private let moveHandler: @MainActor (CGPoint) -> Void
    private var heldDirections: Set<Direction> = []
    private var repeatTask: Task<Void, Never>?

    init(moveHandler: @escaping @MainActor (CGPoint) -> Void) {
        self.moveHandler = moveHandler
    }

    func handlePressesBegan(_ presses: Set<UIPress>) -> Bool {
        var didHandleEvent = false

        for press in presses {
            guard let key = press.key,
                  let direction = direction(for: key)
            else { continue }

            if heldDirections.insert(direction).inserted {
                moveHandler(direction.delta)
            }
            startRepeatIfNeeded()
            didHandleEvent = true
        }

        return didHandleEvent
    }

    func handlePressesEnded(_ presses: Set<UIPress>) -> Bool {
        updateHeldDirections(from: presses)
    }

    func handlePressesCancelled(_ presses: Set<UIPress>) -> Bool {
        updateHeldDirections(from: presses)
    }

    func stop() {
        heldDirections.removeAll()
        repeatTask?.cancel()
        repeatTask = nil
    }

    private func direction(for key: UIKey) -> Direction? {
        switch key.keyCode {
        case .keyboardUpArrow:
            .up
        case .keyboardDownArrow:
            .down
        case .keyboardLeftArrow:
            .left
        case .keyboardRightArrow:
            .right
        default:
            nil
        }
    }

    private func updateHeldDirections(from presses: Set<UIPress>) -> Bool {
        var didHandleEvent = false

        for press in presses {
            guard let key = press.key,
                  let direction = direction(for: key)
            else { continue }

            heldDirections.remove(direction)
            didHandleEvent = true
        }

        if heldDirections.isEmpty {
            stop()
        }

        return didHandleEvent
    }

    private func startRepeatIfNeeded() {
        guard repeatTask == nil, !heldDirections.isEmpty else { return }

        repeatTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: Self.repeatInitialDelay)

                while !Task.isCancelled {
                    self?.repeatHeldDirections()
                    try await Task.sleep(nanoseconds: Self.repeatInterval)
                }
            } catch {
                // Task cancellation is expected when all keys are released.
            }
        }
    }

    private func repeatHeldDirections() {
        guard !heldDirections.isEmpty else {
            repeatTask?.cancel()
            repeatTask = nil
            return
        }

        for direction in heldDirections {
            moveHandler(direction.delta)
        }
    }
}
