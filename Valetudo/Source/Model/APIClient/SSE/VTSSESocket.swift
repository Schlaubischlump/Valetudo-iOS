//
//  VTSSESocket.swift
//  Valetudo
//
//  Created by David Klopp on 29.05.25.
//

import ObjectiveC
import Foundation

public typealias VTListenerToken = UUID

internal protocol VTSSESocketProtocol: NSObjectProtocol {
    associatedtype E: Decodable & Equatable
    associatedtype Action
    
    func register(at url: URL) -> (VTListenerToken, AsyncStream<Action>)
    func remove(token: VTListenerToken)
}


internal final class VTSSESocket<E: Decodable & Equatable>: NSObject, VTSSESocketProtocol, URLSessionDataDelegate {
    
    typealias Action = VTEventAction<E>
    
    private var continuations: [VTListenerToken: AsyncStream<Action>.Continuation] = [:]
    
    private var dataTask: URLSessionDataTask?
    private var isListening: Bool = false
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        config.timeoutIntervalForResource = TimeInterval(INT_MAX)
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    private var buffer: NSMutableData = NSMutableData()
    private let maxNumberOfRetries: Int = 5
    private var numberOfRetries: Int = 0
    
    let endpoint: VTEventEndpoint<E>
    private var listener: Set<VTListenerToken> = Set()

    init(endpoint: VTEventEndpoint<E>) {
        self.endpoint = endpoint
        super.init()
    }
    
    func register(at url: URL) -> (VTListenerToken, AsyncStream<Action>) {
        let token = UUID()
        let stream = AsyncStream<Action> { continuation in
            continuations[token] = continuation
            listener.insert(token)
            
            if !isListening {
                startSSE(at: url)
            }
        }
        return (token, stream)
    }
    
    func remove(token: VTListenerToken) {
        listener.remove(token)
        if listener.isEmpty {
            dataTask?.cancel()
            dataTask = nil
            isListening = false
        }
    }
    
    private func startSSE(at url: URL) {
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        dataTask = session.dataTask(with: request)
        isListening = true
        dataTask?.resume()
        
        continuations.values.forEach { $0.yield(.didConnect) }
    }

    private func completeSSE(at url: URL, reconnect: Bool) {
        isListening = false
        dataTask = nil
        
        guard !listener.isEmpty, reconnect else {
            continuations.values.forEach { $0.yield(.didDisconnect) }
            return
        }
        continuations.values.forEach { $0.yield(.didAttemptReconnect) }
        self.startSSE(at: url)
    }
    
    private func process(eventPayload: String) {
        guard !eventPayload.starts(with: ":") else { return } // skip : sse-keep-alive
        let substrings = eventPayload.components(separatedBy: "\n")
        
        guard substrings.count >= 2 else { return }
        let event = substrings[0].replacing("event: ", with: "")
        let data = substrings[1].replacing("data: ", with: "").data(using: .utf8)
        
        guard endpoint.eventID == event, let data else { return }
        
        do {
            let result = try JSONDecoder().decode(endpoint.decodableType, from: data)
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

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
                
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

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.originalRequest?.url else { return }
        
        if error != nil {
            numberOfRetries += 1
            let retry = numberOfRetries <= maxNumberOfRetries
            completeSSE(at: url, reconnect: retry)
        } else {
            completeSSE(at: url, reconnect: false)
        }
    }
}
