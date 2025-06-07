//
//  VTAPIClient + SSE.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation

extension VTAPIClient {
    
    private func socket<E: Decodable>(
        forEndpoint endpoint: VTEventEndpoint<E>,
        createIfNeeded: Bool) -> VTSSESocket<E>?
    {
        guard let socket = sseSockets[endpoint.eventID] else {
            if (createIfNeeded) {
                // No sockets exists yet. Create one.
                let socket = VTSSESocket(endpoint: endpoint)
                sseSockets[endpoint.eventID] = socket
                return socket
            } else {
                return nil
            }
        }
        guard let typed = socket as? VTSSESocket<E> else {
            fatalError("Type mismatch: \(type(of: socket)) is not \(E.self)")
        }
        return typed
    }
    
    private func sseURL<E: Decodable>(forEndpoint endpoint: VTEventEndpoint<E>) -> URL {
        if E.self == VTMapData.self {
            return self.stateURL
                .appendingPathComponent("map")
                .appendingPathComponent("sse")
        }
        if E.self == VTStateAttributes.self {
            return self.stateURL
                .appendingPathComponent("attributes")
                .appendingPathComponent("sse")
        }
        fatalError("Unsupported endpoint \(endpoint)")
    }
    
    @discardableResult
    func registerEventObserver<E: Decodable & Equatable>(for endpoint: VTEventEndpoint<E>) async
    -> (VTListenerToken, AsyncStream<VTEventAction<E>>) {
        let url = sseURL(forEndpoint: endpoint)
        let socket = socket(forEndpoint: endpoint, createIfNeeded: true)
        return socket!.register(at: url)
    }

    public func removeEventObserver<E: Decodable & Equatable>(token: VTListenerToken, for endpoint: VTEventEndpoint<E>) async {
        let socket = socket(forEndpoint: endpoint, createIfNeeded: false)
        socket?.remove(token: token)
    }
}
