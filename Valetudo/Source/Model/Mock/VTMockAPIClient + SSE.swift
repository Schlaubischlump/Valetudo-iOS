//
//  VTAPIClient + SSE.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation
import os

extension VTMockAPIClient {

    @discardableResult
    func registerEventObserver<E: Decodable & Equatable>(for endpoint: VTEventEndpoint<E>) async -> (VTListenerToken, AsyncStream<VTEventAction<E>>) {
        log(message: "registerSSEObserver not implemented", forSubsystem: .mock, level: .info)
        let token = UUID()
        let stream = AsyncStream<VTEventAction<E>> { continuation in
            continuation.finish() // Immediately close the stream to simulate no events
        }
        
        return (token, stream)
    }

    public func removeEventObserver<E: Decodable>(token: VTListenerToken, for endpoint: VTEventEndpoint<E>) async {
        log(message: "removeSSEObserver not implemented", forSubsystem: .mock, level: .info)
    }
}
