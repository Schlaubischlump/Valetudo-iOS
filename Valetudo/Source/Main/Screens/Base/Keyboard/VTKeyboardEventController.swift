//
//  VTKeyboardEventController.swift
//  Valetudo
//
//  Created by David Klopp on 12.10.25.
//

import UIKit

@MainActor
final class VTKeyboardEventController {
    private static let repeatInitialDelay: UInt64 = 250_000_000
    private static let repeatInterval: UInt64 = 40_000_000

    private let eventHandler: @MainActor (VTKeyboardEvent) -> Bool
    private var heldEvents: Set<VTKeyboardEvent> = []
    private var repeatTask: Task<Void, Never>?

    init(eventHandler: @escaping @MainActor (VTKeyboardEvent) -> Bool) {
        self.eventHandler = eventHandler
    }

    func handlePressesBegan(_ presses: Set<UIPress>) -> Bool {
        var didHandleEvent = false

        for press in presses {
            guard let key = press.key,
                  let event = VTKeyboardEvent(key: key),
                  eventHandler(event)
            else { continue }

            heldEvents.insert(event)
            startRepeatIfNeeded()
            didHandleEvent = true
        }

        return didHandleEvent
    }

    func handlePressesEnded(_ presses: Set<UIPress>) -> Bool {
        updateHeldEvents(from: presses)
    }

    func handlePressesCancelled(_ presses: Set<UIPress>) -> Bool {
        updateHeldEvents(from: presses)
    }

    func stop() {
        heldEvents.removeAll()
        repeatTask?.cancel()
        repeatTask = nil
    }

    private func updateHeldEvents(from presses: Set<UIPress>) -> Bool {
        var didHandleEvent = false

        for press in presses {
            guard let key = press.key,
                  let event = VTKeyboardEvent(key: key)
            else { continue }

            heldEvents.remove(event)
            didHandleEvent = true
        }

        if heldEvents.isEmpty {
            stop()
        }

        return didHandleEvent
    }

    private func startRepeatIfNeeded() {
        guard repeatTask == nil, !heldEvents.isEmpty else { return }

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
        guard !heldEvents.isEmpty else {
            repeatTask?.cancel()
            repeatTask = nil
            return
        }

        for event in heldEvents where eventHandler(event) == false {
            heldEvents.remove(event)
        }

        if heldEvents.isEmpty {
            stop()
        }
    }
}
