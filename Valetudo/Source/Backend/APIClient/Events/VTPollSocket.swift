//
//  VTPollSocket.swift
//  Valetudo
//
//  Created by David Klopp on 19.04.26.
//

import Foundation

internal final actor VTPollSocket<E: Decodable & Equatable & Sendable, O: Sendable>: VTEventSocketProtocol {
    typealias Action = VTEventAction<E>
    
    private var continuations: [VTListenerToken: AsyncStream<Action>.Continuation] = [:]
    private var task: Task<Void, Never>?
    private var taskID: UUID?
    private var lastResult: E?
    
    let endpoint: VTEventEndpoint<E, O>
    private let interval: TimeInterval
    
    init(endpoint: VTEventEndpoint<E, O>) {
        self.endpoint = endpoint
        self.interval = 5
    }
    
    init(endpoint: VTEventEndpoint<E, O>, interval: TimeInterval) {
        self.endpoint = endpoint
        self.interval = max(interval, 0.1)
    }

    func register(at url: URL) -> (VTListenerToken, AsyncStream<Action>) {
        let token = UUID()
        let stream = AsyncStream<Action> { continuation in
            continuations[token] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.remove(token: token) }
            }
            
            if task == nil {
                startPolling(at: url)
            }
        }
        return (token, stream)
    }
    
    func remove(token: VTListenerToken) {
        continuations[token] = nil
        
        if continuations.isEmpty {
            stopPolling()
        }
    }
    
    // MARK: - Polling Lifecycle
    
    private func startPolling(at url: URL) {
        let currentTaskID = UUID()
        taskID = currentTaskID
        
        task = Task {
            defer {
                if taskID == currentTaskID {
                    task = nil
                    taskID = nil
                    lastResult = nil
                }
            }
            
            for c in continuations.values { c.yield(.didConnect) }
            
            while !Task.isCancelled && !continuations.isEmpty {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    print(String(data: data, encoding: .utf8)!)
                    try validate(response: response)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601Flexible
                    let result = try decoder.decode(endpoint.decodableType, from: data)
                    
                    if result != lastResult {
                        lastResult = result
                        for c in continuations.values { c.yield(.didReceiveData(result)) }
                    }
                } catch is CancellationError {
                    break
                } catch {
                    if Task.isCancelled {
                        break
                    }
                    
                    for c in continuations.values { c.yield(.didReceiveError(error.localizedDescription)) }
                }
                
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    private func stopPolling() {
        task?.cancel()
        task = nil
        taskID = nil
        lastResult = nil
        for continuation in continuations.values {
            continuation.yield(.didDisconnect)
        }
    }
    
    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
