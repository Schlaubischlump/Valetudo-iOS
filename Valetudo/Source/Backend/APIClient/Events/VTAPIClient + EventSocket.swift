//
//  VTAPIClient + SSE.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation

public extension VTAPIClient {
    private func sseSocket<E: Decodable, O: Sendable>(
        forEndpoint endpoint: VTEventEndpoint<E, O>,
        createIfNeeded: Bool
    ) -> VTSSESocket<E, O>? {
        eventSocket(VTSSESocket<E, O>.self, forEndpoint: endpoint, createIfNeeded: createIfNeeded)
    }

    private func pollSocket<E: Decodable, O>(
        forEndpoint endpoint: VTEventEndpoint<E, O>,
        createIfNeeded: Bool
    ) -> VTPollSocket<E, O>? {
        eventSocket(VTPollSocket<E, O>.self, forEndpoint: endpoint, createIfNeeded: createIfNeeded)
    }

    private func eventSocket<S: VTEventSocketProtocol>(
        _: S.Type,
        forEndpoint endpoint: VTEventEndpoint<S.E, S.O>,
        createIfNeeded: Bool
    ) -> S? {
        guard let socket = eventSockets[endpoint.eventID] else {
            guard createIfNeeded else { return nil }

            let socket = S(endpoint: endpoint, url: eventURL(forEndpoint: endpoint))
            eventSockets[endpoint.eventID] = socket
            return socket
        }

        guard let typed = socket as? S else {
            fatalError("Type mismatch: \(type(of: socket)) is not \(S.self)")
        }

        return typed
    }

    private func eventURL(forEndpoint endpoint: VTEventEndpoint<some Decodable, some Any>) -> URL {
        let url = switch endpoint.eventID {
        case .map: stateURL.appendingPathComponent("map")
        case .stateAttributes: stateURL.appendingPathComponent("attributes")
        case .valetudoEvent where !endpoint.useSSE: eventsURL
        case .valetudoEvent: fatalError("ValetudoEvent does not support SSE")
        case .log: logURL.appendingPathComponent("content")
        }

        return endpoint.useSSE ? url.appendingPathComponent("sse") : url
    }

    // MARK: - 1.1.3 SSE

    /// Registers a listener for an event endpoint.
    ///
    /// Sockets are shared per `endpoint.eventID`: multiple listeners for the same endpoint reuse the same `VTSSESocket` or `VTPollSocket`.
    /// This means there is only one active SSE connection or polling loop per endpoint, and each received value is broadcast to all registered listeners.
    ///
    @discardableResult
    func registerEventObserver<E: Decodable & Equatable & Sendable, O>(for endpoint: VTEventEndpoint<E, O>) async
        -> (VTListenerToken, AsyncStream<VTEventAction<O>>)
    {
        var token: VTListenerToken!
        var asyncStream: AsyncStream<VTEventAction<E>>!
        if endpoint.useSSE {
            let socket = sseSocket(forEndpoint: endpoint, createIfNeeded: true)
            (token, asyncStream) = await socket!.register()
        } else {
            let socket = pollSocket(forEndpoint: endpoint, createIfNeeded: true)
            (token, asyncStream) = await socket!.register()
        }

        return (token, asyncStream.mapStream { action in action.map { endpoint.transform($0) } })
    }

    func removeEventObserver(token: VTListenerToken, for endpoint: VTEventEndpoint<some Decodable & Equatable & Sendable, some Any>) async {
        let socket: (any VTEventSocketProtocol)? = if endpoint.useSSE {
            sseSocket(forEndpoint: endpoint, createIfNeeded: false)
        } else {
            pollSocket(forEndpoint: endpoint, createIfNeeded: false)
        }
        await socket?.remove(token: token)
    }
}
