//
//  VTSSEEndpoint.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation


/// The Valetudo event identifiers used to route endpoint payloads.
///
/// Raw values match the event names emitted by Valetudo and are used to filter incoming SSE
/// payloads before decoding them with the endpoint's payload type.
enum VTEventEndpointEventID: String {
    /// The robot state attributes update event.
    case stateAttributes = "StateAttributesUpdated"

    /// The map update event.
    case map = "MapUpdated"

    /// The Valetudo interaction event.
    case valetudoEvent = "ValetudoEventUpdated"
}


/// A typed descriptor for a Valetudo event stream endpoint.
///
/// `VTEventEndpoint` pairs the Valetudo event identifier with the concrete payload type used
/// for decoding and the output type delivered to event consumers. Most endpoints decode and
/// emit the same type, but an endpoint can provide a transform when the wire representation
/// differs from the value that should be exposed by the API client.
///
/// - Note: `useSSE` indicates whether consumers should use the server-sent events socket
///   for this endpoint. Endpoints with `useSSE` set to `false` should use the polling socket
///   fallback. Not all endpoints support sse.
public struct VTEventEndpoint<E: Decodable & Equatable & Sendable, O: Sendable>: Sendable {
    /// An endpoint that emits the robot's current state attributes.
    public static var stateAttributes: VTEventEndpoint<VTStateAttributeList, VTStateAttributeList> {
        .init(type: VTStateAttributeList.self, eventID: .stateAttributes, useSSE: true)
    }
    
    /// An endpoint that emits complete map updates.
    public static var map: VTEventEndpoint<VTMapData, VTMapData> {
        .init(type: VTMapData.self, eventID: .map, useSSE: true)
    }
    
    /// An endpoint that emits Valetudo interaction events.
    ///
    /// The endpoint decodes the wire payload as type-erased event wrappers, then unwraps them
    /// into concrete ``VTValetudoEvent`` values before delivery.
    public static var valetudoEvent: VTEventEndpoint<[VTAnyValetudoEvent], [any VTValetudoEvent]> {
        .init(
            decodableType: [VTAnyValetudoEvent].self,
            outputType: [(any VTValetudoEvent)].self,
            eventID: .valetudoEvent,
            useSSE: false
        ) { anyEvents in
            anyEvents.map(\.event)
        }
    }
    
    internal let decodableType: E.Type
    internal let outputType: O.Type
    internal let eventID: VTEventEndpointEventID
    internal let useSSE: Bool
    internal let transform: (@Sendable (E) -> O)
    
    private init(
        decodableType: E.Type,
        outputType: O.Type,
        eventID: VTEventEndpointEventID,
        useSSE: Bool,
        transform: @escaping (@Sendable (E) -> O)
    ) {
        self.decodableType = decodableType
        self.outputType = outputType
        self.eventID = eventID
        self.useSSE = useSSE
        self.transform = transform
    }
}

fileprivate extension VTEventEndpoint where E == O {
    init(type: E.Type, eventID: VTEventEndpointEventID, useSSE: Bool) {
        self.init(decodableType: type, outputType: type, eventID: eventID, useSSE: useSSE) { e in e}
    }
}
