//
//  VTMoveCapability.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//

public enum VTManualControlActionType: String, Encodable, Sendable {
    case enable
    case disable
    case move
}

public enum VTMoveDirection: String, Codable, Sendable {
    case forward = "forward"
    case backward = "backward"
    case rotateClockwise = "rotate_clockwise"
    case rotateCounterclockwise = "rotate_counterclockwise"
}

public struct VTManualControlAction: Encodable, Sendable {
    let action: VTManualControlActionType
    let movementCommand: VTMoveDirection?

    private init(action: VTManualControlActionType, movementCommand: VTMoveDirection? = nil) {
        self.action = action
        self.movementCommand = movementCommand
    }
    
    public static let enable  = VTManualControlAction(action: .enable, movementCommand: nil)
    public static let disable = VTManualControlAction(action: .disable, movementCommand: nil)
    static func move(direction: VTMoveDirection) -> VTManualControlAction {
        VTManualControlAction(action: .move, movementCommand: direction)
    }
}


