//
//  VTMoveCapability.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//
import Foundation

enum VTHighResolutionManualControlActionType: String, Encodable, Hashable, Sendable {
    case enable
    case disable
    case move
}

struct VTHighResolutionManualControlVector: Codable, Hashable, Sendable {
    let velocity: CGFloat
    let angle: CGFloat
    //let metaData: [String: VTAnyDecodable]? we would need an any encodable here
    
    init(velocity: CGFloat, angle: CGFloat) {
        self.velocity = max(min(velocity, 1.0), -1.0)
        self.angle = max(min(angle, 180.0), -180.0)
    }
}

struct VTHighResolutionManualControlAction: Encodable, Hashable, Sendable  {
    let action: VTHighResolutionManualControlActionType
    let vector: VTHighResolutionManualControlVector?

    private init(action: VTHighResolutionManualControlActionType, vector: VTHighResolutionManualControlVector? = nil) {
        self.action = action
        self.vector = vector
    }
    
    static let enable  = VTHighResolutionManualControlAction(action: .enable, vector: nil)
    static let disable = VTHighResolutionManualControlAction(action: .disable, vector: nil)
    static func move(vector: VTHighResolutionManualControlVector) -> VTHighResolutionManualControlAction {
        VTHighResolutionManualControlAction(action: .move, vector: vector)
    }
}


