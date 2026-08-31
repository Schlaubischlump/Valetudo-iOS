//
//  VTManualControlDriver.swift
//  Valetudo
//
//  Created by David Klopp on 31.08.26.
//

import Foundation

/// Adapts Valetudo's two manual-control capabilities to the shared control UI.
enum VTManualControlDriver {
    case directional(supportedDirections: Set<VTMoveDirection>)
    case highResolution

    static func resolve(
        capabilities: Set<VTCapability>,
        client: VTAPIClientProtocol
    ) async -> VTManualControlDriver? {
        if capabilities.contains(.highResolutionManualControl) {
            return .highResolution
        }

        guard capabilities.contains(.manualControl) else { return nil }
        let supportedDirections = await Set(
            (try? client.getManualControlSupportedMovementDirections()) ?? []
        )
        return .directional(supportedDirections: supportedDirections)
    }

    var preferredMode: VTManualControlMode {
        switch self {
        case .directional: .keys
        case .highResolution: .joystick
        }
    }

    func isEnabled(using client: VTAPIClientProtocol) async throws -> Bool {
        switch self {
        case .directional:
            try await client.getManualControlIsEnabled()
        case .highResolution:
            try await client.getHighResolutionManualControlIsEnabled()
        }
    }

    func setEnabled(_ enabled: Bool, using client: VTAPIClientProtocol) async throws {
        switch (self, enabled) {
        case (.directional, true):
            try await client.enableManualControl()
        case (.directional, false):
            try await client.disableManualControl()
        case (.highResolution, true):
            try await client.enableHighResolutionManualControl()
        case (.highResolution, false):
            try await client.disableHighResolutionManualControl()
        }
    }

    func send(_ vector: VTManualControlVector, using client: VTAPIClientProtocol) async throws {
        switch self {
        case let .directional(supportedDirections):
            let direction: VTMoveDirection? = if vector.velocity > 0.3,
                                                 supportedDirections.contains(.forward)
            {
                .forward
            } else if vector.velocity < -0.3,
                      supportedDirections.contains(.backward)
            {
                .backward
            } else if vector.angle > 30,
                      supportedDirections.contains(.rotateClockwise)
            {
                .rotateClockwise
            } else if vector.angle < -30,
                      supportedDirections.contains(.rotateCounterclockwise)
            {
                .rotateCounterclockwise
            } else {
                nil
            }

            if let direction {
                try await client.manualControlMove(direction: direction)
            }

        case .highResolution:
            try await client.highResolutionManualControlMove(
                angle: vector.angle,
                velocity: vector.velocity
            )
        }
    }
}
