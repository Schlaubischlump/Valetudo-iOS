//
//  VTEventAction.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//

public enum VTEventAction<E: Decodable & Equatable & Sendable>: Equatable, Sendable {
    case didConnect
    case didAttemptReconnect
    case didDisconnect
    case didCompleteWithError
    case didReceiveKeepAlive
    case didReceiveError(String)
    case didReceiveData(E)
}
