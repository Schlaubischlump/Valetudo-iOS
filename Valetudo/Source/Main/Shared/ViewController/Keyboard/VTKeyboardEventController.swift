//
//  VTKeyboardEventController.swift
//  Valetudo
//
//  Created by David Klopp on 12.10.25.
//

import UIKit

/// Normalizes raw hardware keyboard press events into repeated callback delivery for controllers.
///
/// UIKit exposes physical keyboard input through `pressesBegan`, `pressesEnded`, and
/// `pressesCancelled`, but leaves repeat handling and held-key tracking to the app. This helper
/// centralizes that behavior so base controllers can forward raw press events into one place and
/// subclasses only need to implement a single semantic callback like `didReceiveKeyEvent(_:)`.
///
/// Behavior:
/// - Emits the pressed `UIKey` immediately on key-down when the handler accepts it.
/// - Tracks accepted keys while they remain held.
/// - Replays those keys after a short initial delay at a fixed repeat interval.
/// - Stops repeating as soon as the corresponding key-up or cancellation event arrives.
///
/// This keeps keyboard interaction consistent across `VTViewController` and
/// `VTCollectionViewController` without duplicating responder-chain and repeat-loop logic in every
/// screen.
@MainActor
final class VTKeyboardEventController {
    private static let repeatInitialDelay: UInt64 = 250_000_000
    private static let repeatInterval: UInt64 = 40_000_000

    private let eventHandler: @MainActor (UIKey) -> Bool
    private var heldKeys: Set<UIKey> = []
    private var repeatTask: Task<Void, Never>?

    /// Creates a keyboard event controller.
    ///
    /// - Parameter eventHandler:
    ///   Called for each accepted hardware key event. Return `true` to mark the key as handled and
    ///   opt it into repeat behavior while held, or `false` to leave it to the normal responder
    ///   chain.
    init(eventHandler: @escaping @MainActor (UIKey) -> Bool) {
        self.eventHandler = eventHandler
    }

    /// Processes raw key-down events from a responder's `pressesBegan`.
    ///
    /// Any key accepted by `eventHandler` is remembered as held and starts participating in repeat
    /// delivery until a matching end or cancel event arrives.
    func handlePressesBegan(_ presses: Set<UIPress>) -> Bool {
        var didHandleEvent = false

        for press in presses {
            guard let key = press.key,
                  eventHandler(key)
            else { continue }

            heldKeys.insert(key)
            startRepeatIfNeeded()
            didHandleEvent = true
        }

        return didHandleEvent
    }

    /// Processes key-up events from a responder's `pressesEnded`.
    func handlePressesEnded(_ presses: Set<UIPress>) -> Bool {
        updateHeldEvents(from: presses)
    }

    /// Processes cancelled key sequences from a responder's `pressesCancelled`.
    func handlePressesCancelled(_ presses: Set<UIPress>) -> Bool {
        updateHeldEvents(from: presses)
    }

    /// Clears all held-key state and stops any active repeat loop.
    ///
    /// Call this when the owning view controller is leaving the screen so no stale repeat task can
    /// outlive the responder that created it.
    func stop() {
        heldKeys.removeAll()
        repeatTask?.cancel()
        repeatTask = nil
    }

    private func updateHeldEvents(from presses: Set<UIPress>) -> Bool {
        var didHandleEvent = false

        for press in presses {
            guard let key = press.key else { continue }

            heldKeys.remove(key)
            didHandleEvent = true
        }

        if heldKeys.isEmpty {
            stop()
        }

        return didHandleEvent
    }

    private func startRepeatIfNeeded() {
        guard repeatTask == nil, !heldKeys.isEmpty else { return }

        repeatTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: Self.repeatInitialDelay)

                while !Task.isCancelled {
                    self?.repeatHeldEvents()
                    try await Task.sleep(nanoseconds: Self.repeatInterval)
                }
            } catch {
                // Task cancellation is expected when all keys are released.
            }
        }
    }

    private func repeatHeldEvents() {
        guard !heldKeys.isEmpty else {
            repeatTask?.cancel()
            repeatTask = nil
            return
        }

        for key in heldKeys where eventHandler(key) == false {
            heldKeys.remove(key)
        }

        if heldKeys.isEmpty {
            stop()
        }
    }
}
