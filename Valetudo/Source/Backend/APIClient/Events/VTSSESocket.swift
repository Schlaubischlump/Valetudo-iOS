//
//  VTSSESocket.swift
//  Valetudo
//
//  Created by David Klopp on 29.05.25.
//
import Foundation

internal final actor VTSSESocket<E: Decodable & Equatable & Sendable, O: Sendable>: VTEventSocketProtocol {
    typealias Action = VTEventAction<E>
    
    private var continuations: [VTListenerToken: AsyncStream<Action>.Continuation] = [:]
    private var task: Task<Void, Never>?
    private var taskID: UUID?
    
    let endpoint: VTEventEndpoint<E, O>
    private let maxNumberOfRetries = 5
    private var numberOfRetries = 0
    
    init(endpoint: VTEventEndpoint<E, O>) {
        self.endpoint = endpoint
    }
    
    func register(at url: URL) -> (VTListenerToken, AsyncStream<Action>) {
        let token = UUID()
        let stream = AsyncStream<Action> { continuation in
            continuations[token] = continuation
            continuation.onTermination = { [weak self] _ in
               Task { await self?.remove(token: token) }
            }
            
            if task == nil {
                startSSE(at: url)
            }
        }
        return (token, stream)
    }
    
    func remove(token: VTListenerToken) {
        continuations[token] = nil
        
        if continuations.isEmpty {
            stopSSE()
        }
    }
    
    // MARK: - SSE Lifecycle
    
    private func process(eventPayload: String) {
        guard !eventPayload.starts(with: ":") else { return } // skip : sse-keep-alive
        let substrings = eventPayload.components(separatedBy: "\n")
        
        guard substrings.count >= 2 else { return }
        let event = substrings[0].replacing("event: ", with: "")
        let data = substrings[1].replacing("data: ", with: "").data(using: .utf8)
        
        guard endpoint.eventID == event, let data else { return }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601Flexible
            let result = try decoder.decode(endpoint.decodableType, from: data)
            continuations.values.forEach { $0.yield(.didReceiveData(result)) }
        } catch {
            continuations.values.forEach { $0.yield(.didReceiveError(error.localizedDescription)) }
        }
    }
    
    private func searchForEvent(inBuffer: NSData, searchRange: NSRange) -> NSRange? {
        for whitespace in ["\n", "\r"] {
            let delimiter =  "\(whitespace)\(whitespace)".data(using: .utf8)!
            let foundRange = inBuffer.range(of: delimiter, in: searchRange)
            if foundRange.location != NSNotFound {
                return foundRange
            }
        }
        return nil
    }
    
    private func startSSE(at url: URL) {
        let currentTaskID = UUID()
        taskID = currentTaskID
        
        task = Task {
            defer {
                if taskID == currentTaskID {
                    task = nil
                    taskID = nil
                    numberOfRetries = 0
                }
            }
            
            for c in continuations.values { c.yield(.didConnect) }

            let buffer = NSMutableData() // accumulate partial SSE data

            repeat {
                do {
                    let (bytes, _) = try await URLSession.shared.bytes(from: url)
                    
                    for try await byte in bytes {
                        var byte = UInt8(byte)
                        buffer.append(&byte, length: 1)

                        var events: [String] = []
                        var searchRange =  NSRange(location: 0, length: buffer.length)
                        while let foundRange = searchForEvent(inBuffer: buffer, searchRange: searchRange) {
                            let dataLengthBeforeDelimiter = foundRange.location - searchRange.location
                            if dataLengthBeforeDelimiter > 0 {
                                let dataRange = NSRange(location: searchRange.location, length: dataLengthBeforeDelimiter)
                                let eventPayload = String(bytes: buffer.subdata(with: dataRange), encoding: .utf8)
                                if let eventPayload {
                                    events.append(eventPayload)
                                }
                            }
                            searchRange.location = foundRange.location + foundRange.length
                            searchRange.length = buffer.length - searchRange.location
                        }
                        
                        buffer.replaceBytes(in: NSRange(location: 0, length: searchRange.location), withBytes: nil, length: 0)
                        events.forEach { process(eventPayload: $0) }
                    }

                    // Connection closed normally
                    for c in continuations.values { c.yield(.didDisconnect) }
                    break
                } catch is CancellationError {
                    break
                } catch {
                    if Task.isCancelled {
                        break
                    }
                    
                    numberOfRetries += 1
                    let shouldRetry = numberOfRetries <= maxNumberOfRetries && !continuations.isEmpty

                    if shouldRetry {
                        for c in continuations.values { c.yield(.didAttemptReconnect) }
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        continue
                    } else {
                        for c in continuations.values { c.yield(.didDisconnect) }
                        break
                    }
                }
            } while true
        }
    }

    private func stopSSE() {
        task?.cancel()
        task = nil
        taskID = nil
        for continuation in continuations.values {
            continuation.yield(.didDisconnect)
        }
    }
}
