//
//  VTEventSocketProtocol.swift
//  Valetudo
//
//  Created by David Klopp on 20.04.26.
//
import Foundation

public typealias VTListenerToken = UUID

internal protocol VTEventSocketProtocol: Actor {
    associatedtype E: Decodable & Sendable & Equatable
    associatedtype O: Sendable
    associatedtype Action: Sendable
    
    var endpoint: VTEventEndpoint<E, O> { get }
    init(endpoint: VTEventEndpoint<E, O>)
    
    func register(at url: URL) -> (VTListenerToken, AsyncStream<Action>)
    func remove(token: VTListenerToken)
}
