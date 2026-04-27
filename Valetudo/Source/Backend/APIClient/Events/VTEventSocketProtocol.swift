//
//  VTEventSocketProtocol.swift
//  Valetudo
//
//  Created by David Klopp on 20.04.26.
//
import Foundation

/// A token used to remove a registered event socket listener.
public typealias VTListenerToken = UUID

/// The common actor contract for event sockets that broadcast endpoint actions to listeners.
///
/// A socket owns the transport URL for a single `VTEventEndpoint` and exposes received updates
/// as `AsyncStream` values. Implementations decide how the transport is driven, such as polling
/// or server-sent events, but they share the same listener registration and removal model.
protocol VTEventSocketProtocol: Actor {
    /// The decoded payload type produced by the endpoint transport.
    associatedtype E: Decodable & Sendable & Equatable

    /// The transformed output type exposed by the endpoint descriptor.
    associatedtype O: Sendable

    /// The action type emitted to registered listeners.
    associatedtype Action: Sendable

    /// The endpoint served by this socket.
    var endpoint: VTEventEndpoint<E, O> { get }

    /// Creates a socket for an endpoint and its transport URL.
    init(endpoint: VTEventEndpoint<E, O>, url: URL)

    /// Registers a listener for events received by this socket.
    ///
    /// The returned token must be passed to `remove(token:)` to unregister the listener manually.
    func register() -> (VTListenerToken, AsyncStream<Action>)

    /// Removes a previously registered listener.
    func remove(token: VTListenerToken)
}
