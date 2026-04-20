//
//  VTAPIClient + SSE.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation

extension VTAPIClient {
    
    private func sseSocket<E: Decodable, O: Sendable>(
        forEndpoint endpoint: VTEventEndpoint<E, O>,
        createIfNeeded: Bool) -> VTSSESocket<E, O>?
    {
        eventSocket(VTSSESocket<E, O>.self, forEndpoint: endpoint, createIfNeeded: createIfNeeded)
    }
    
    private func pollSocket<E: Decodable, O>(
        forEndpoint endpoint: VTEventEndpoint<E, O>,
        createIfNeeded: Bool) -> VTPollSocket<E, O>?
    {
        eventSocket(VTPollSocket<E, O>.self, forEndpoint: endpoint, createIfNeeded: createIfNeeded)
    }
    
    private func eventSocket<S: VTEventSocketProtocol>(
        _ ty: S.Type,
        forEndpoint endpoint: VTEventEndpoint<S.E, S.O>,
        createIfNeeded: Bool
    ) -> S? {
        guard let socket = eventSockets[endpoint.eventID] else {
            guard createIfNeeded else { return nil }

            let socket = S(endpoint: endpoint)
            eventSockets[endpoint.eventID] = socket
            return socket
        }

        guard let typed = socket as? S else {
            fatalError("Type mismatch: \(type(of: socket)) is not \(S.self)")
        }

        return typed
    }
    
    private func eventURL<E: Decodable, O>(forEndpoint endpoint: VTEventEndpoint<E, O>) -> URL {
        switch (endpoint.eventID) {
        case VTEventEndpoint<E, O>.map.eventID:
            if endpoint.suppportsSSE {
                self.stateURL.appendingPathComponent("map").appendingPathComponent("sse")
            } else {
                self.stateURL.appendingPathComponent("map")
            }
        case VTEventEndpoint<E, O>.stateAttributes.eventID:
            if endpoint.suppportsSSE {
                self.stateURL.appendingPathComponent("attributes").appendingPathComponent("sse")
            } else {
                self.stateURL.appendingPathComponent("attributes")
            }
        case VTEventEndpoint<E, O>.valetudoEvent.eventID:
            self.eventsURL
        default:
            fatalError("Unsupported endpoint \(endpoint)")
        }
    }
    
    // MARK: - 1.1.3 SSE
    
    /// Registers a listener for an event endpoint.
    ///
    /// Sockets are shared per `endpoint.eventID`: multiple listeners for the same endpoint reuse the same `VTSSESocket` or `VTPollSocket`.
    /// This means there is only one active SSE connection or polling loop per endpoint, and each received value is broadcast to all registered listeners.
    ///
    @discardableResult
    func registerEventObserver<E: Decodable & Equatable & Sendable, O>(for endpoint: VTEventEndpoint<E, O>) async
    -> (VTListenerToken, AsyncStream<VTEventAction<O>>) {
        let url = eventURL(forEndpoint: endpoint)
        var token: VTListenerToken!
        var asyncStream : AsyncStream<VTEventAction<E>>!
        if endpoint.suppportsSSE {
            let socket = sseSocket(forEndpoint: endpoint, createIfNeeded: true)
            (token, asyncStream) = await socket!.register(at: url)
        } else {
            let socket = pollSocket(forEndpoint: endpoint, createIfNeeded: true)
            (token, asyncStream) = await socket!.register(at: url)
        }
            
        return (token, asyncStream.mapStream { action in action.map { endpoint.transform($0) } })
    }

    public func removeEventObserver<E: Decodable & Equatable & Sendable, O>(token: VTListenerToken, for endpoint: VTEventEndpoint<E, O>) async {
        let socket: (any VTEventSocketProtocol)? = if endpoint.suppportsSSE {
            sseSocket(forEndpoint: endpoint, createIfNeeded: false)
        } else {
            pollSocket(forEndpoint: endpoint, createIfNeeded: false)
        }
        await socket?.remove(token: token)
    }
}
