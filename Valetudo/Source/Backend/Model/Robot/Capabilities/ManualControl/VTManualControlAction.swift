//
//  VTManualControlAction.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//

enum VTManualControlActionType: String, Encodable {
    case enable
    case disable
    case move
}

public enum VTMoveDirection: String, Codable, Sendable {
    case forward
    case backward
    case rotateClockwise = "rotate_clockwise"
    case rotateCounterclockwise = "rotate_counterclockwise"
}

struct VTManualControlAction: Encodable {
    let action: VTManualControlActionType
    let movementCommand: VTMoveDirection?

    private init(action: VTManualControlActionType, movementCommand: VTMoveDirection? = nil) {
        self.action = action
        self.movementCommand = movementCommand
    }

    static let enable = VTManualControlAction(action: .enable, movementCommand: nil)
    static let disable = VTManualControlAction(action: .disable, movementCommand: nil)
    static func move(direction: VTMoveDirection) -> VTManualControlAction {
        VTManualControlAction(action: .move, movementCommand: direction)
    }
}
