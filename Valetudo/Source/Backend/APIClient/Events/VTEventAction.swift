//
//  VTEventAction.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//

/// An event emitted by an event socket.
///
/// `VTEventAction` wraps both socket lifecycle updates and decoded endpoint payloads in the
/// `AsyncStream` returned to event observers.
public enum VTEventAction<E: Sendable>: Sendable {
    /// The socket established a connection to the endpoint.
    case didConnect

    /// The socket is attempting to reconnect after an interruption.
    case didAttemptReconnect

    /// The socket disconnected from the endpoint.
    case didDisconnect

    /// The socket finished because an unrecoverable error occurred.
    case didCompleteWithError

    /// The socket received a keep-alive event from the endpoint.
    case didReceiveKeepAlive

    /// The socket received an endpoint-level error message.
    case didReceiveError(String)

    /// The socket received and decoded endpoint data.
    case didReceiveData(E)

    /// Returns an action with received data transformed to another payload type.
    func map<O: Sendable>(_ transform: (E) -> O) -> VTEventAction<O> {
        switch self {
        case let .didReceiveData(e): .didReceiveData(transform(e))
        case .didConnect: .didConnect
        case .didAttemptReconnect: .didAttemptReconnect
        case .didDisconnect: .didDisconnect
        case .didCompleteWithError: .didCompleteWithError
        case .didReceiveKeepAlive: .didReceiveKeepAlive
        case let .didReceiveError(msg): .didReceiveError(msg)
        }
    }
}
