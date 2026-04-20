//
//  VTEventAction.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//

public enum VTEventAction<E: Sendable>: Sendable {
    case didConnect
    case didAttemptReconnect
    case didDisconnect
    case didCompleteWithError
    case didReceiveKeepAlive
    case didReceiveError(String)
    case didReceiveData(E)
    
    func map<O: Sendable>(_ transform: (E) -> O) -> VTEventAction<O> {
        switch self {
        case .didReceiveData(let e): .didReceiveData(transform(e))
        case .didConnect: .didConnect
        case .didAttemptReconnect: .didAttemptReconnect
        case .didDisconnect: .didDisconnect
        case .didCompleteWithError: .didCompleteWithError
        case .didReceiveKeepAlive: .didReceiveKeepAlive
        case .didReceiveError(let msg): .didReceiveError(msg)
        }
    }
}
