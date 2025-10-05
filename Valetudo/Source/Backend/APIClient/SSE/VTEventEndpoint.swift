//
//  VTSSEEndpoint.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation

public enum VTEventEndpoint<E: Decodable & Equatable & Sendable>: Sendable {
    typealias T = E
    
    case endpoint(E.Type)
    
    // Convenience static cases to avoid `.endpoint(...)` boilerplate
    public static var stateAttributes: VTEventEndpoint<VTStateAttributeList> { .endpoint(VTStateAttributeList.self) }
    public static var map: VTEventEndpoint<VTMapData> { .endpoint(VTMapData.self) }
    
    internal var decodableType: E.Type {
        if case let .endpoint(ty) = self { return ty }
        fatalError("Unknown endpoint!")
    }
    
    internal var eventID: String {
        if case let .endpoint(ty) = self {
            if (ty == VTStateAttributeList.self) { return "StateAttributesUpdated" }
            if (ty == VTMapData.self)         { return "MapUpdated"             }
            fatalError("Unknown endpoint for type: \(ty)")
        }
        fatalError("Unknown endpoint: \(self)")
    }
}
