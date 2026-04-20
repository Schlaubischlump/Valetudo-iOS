//
//  VTSSEEndpoint.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation

public enum VTEventEndpoint<E: Decodable & Equatable & Sendable, O: Sendable>: Sendable {
    /// E = Decodable type received by backend
    /// O = Output type
    case endpoint(E.Type, O.Type, String, Bool)
    
    // Convenience static cases to avoid `.endpoint(...)` boilerplate
    public static var stateAttributes: VTEventEndpoint<VTStateAttributeList, VTStateAttributeList> {
        .endpoint(VTStateAttributeList.self, VTStateAttributeList.self, "StateAttributesUpdated", true)
    }
    
    public static var map: VTEventEndpoint<VTMapData, VTMapData> {
        .endpoint(VTMapData.self, VTMapData.self, "MapUpdated", true)
    }
    public static var valetudoEvent: VTEventEndpoint<[VTAnyValetudoEvent], [any VTValetudoEvent]> {
        .endpoint([VTAnyValetudoEvent].self, [(any VTValetudoEvent)].self, "ValetudoEvent", false)
    }
    
    func transform(_ e: E) -> O {
        if let anyEvent = e as? [VTAnyValetudoEvent], let result = anyEvent.map(\.event) as? O {
            return result
        }

        if let result = e as? O {
            return result
        }

        fatalError("Unsupported transform from \(E.self) to \(O.self)")
    }
    
    internal var decodableType: E.Type {
        if case let .endpoint(ty, _, _, _) = self { return ty }
        fatalError("Unknown endpoint!")
    }
    
    internal var eventID: String {
        if case let .endpoint(_, _, eventId, _) = self {
            return eventId
        }
        fatalError("Unknown endpoint: \(self)")
    }
    
    internal var suppportsSSE: Bool {
        if case let .endpoint(_, _, _, support) = self {
            return support
        }
        fatalError("Unknown endpoint: \(self)")
    }
}
