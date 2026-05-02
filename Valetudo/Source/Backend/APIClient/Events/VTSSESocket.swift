//
//  VTSSESocket.swift
//  Valetudo
//
//  Created by David Klopp on 29.05.25.
//
import Foundation

/// A shared server-sent events socket for endpoints consumed through SSE.
///
/// `VTSSESocket` owns one streaming task per endpoint instance and broadcasts lifecycle and
/// decoded data actions to every registered listener. The stream starts when the first listener
/// is registered, attempts a limited number of reconnects after transient failures, and stops
/// when the final listener is removed.
final actor VTSSESocket<E: Decodable & Equatable & Sendable, O: Sendable>: VTEventSocketProtocol {
    private struct SSEEventBoundary {
        let totalLength: Int
        let delimiterLength: Int
    }

    private struct SSEMessage {
        let event: String?
        let data: String
        let isKeepAlive: Bool
    }

    typealias Action = VTEventAction<E>

    private var continuations: [VTListenerToken: AsyncStream<Action>.Continuation] = [:]
    private var task: Task<Void, Never>?
    private var taskID: UUID?

    let endpoint: VTEventEndpoint<E, O>
    private let url: URL
    private let maxNumberOfRetries = 5
    private var numberOfRetries = 0

    /// Creates an SSE socket for an event endpoint and its streaming URL.
    init(endpoint: VTEventEndpoint<E, O>, url: URL) {
        self.endpoint = endpoint
        self.url = url
    }

    /// Registers a listener and starts the SSE stream when this is the first active listener.
    func register() -> (VTListenerToken, AsyncStream<Action>) {
        let token = UUID()
        let stream = AsyncStream<Action> { continuation in
            continuations[token] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.remove(token: token) }
            }

            if task == nil {
                startSSE()
            }
        }
        return (token, stream)
    }

    /// Removes a listener and stops the SSE stream when no listeners remain.
    func remove(token: VTListenerToken) {
        continuations[token] = nil

        if continuations.isEmpty {
            stopSSE()
        }
    }

    // MARK: - SSE Lifecycle

    /// Parses a complete SSE frame into its event name and concatenated data payload.
    private func parse(eventPayload: String) -> SSEMessage? {
        let normalizedPayload = eventPayload
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalizedPayload.split(separator: "\n", omittingEmptySubsequences: false)

        var event: String?
        var dataLines: [String] = []
        var sawNonCommentContent = false

        for line in lines {
            if line.hasPrefix(":") {
                continue
            }

            if line.isEmpty {
                continue
            }

            sawNonCommentContent = true

            let parts = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let field = String(parts[0])
            let value: String
            if parts.count > 1 {
                let rawValue = String(parts[1])
                value = rawValue.hasPrefix(" ") ? String(rawValue.dropFirst()) : rawValue
            } else {
                value = ""
            }

            switch field {
            case "event":
                event = value
            case "data":
                dataLines.append(value)
            default:
                break
            }
        }

        if !sawNonCommentContent {
            return SSEMessage(event: nil, data: "", isKeepAlive: true)
        }

        return SSEMessage(event: event, data: dataLines.joined(separator: "\n"), isKeepAlive: false)
    }

    /// Decodes a complete SSE payload and broadcasts matching endpoint data.
    private func process(eventPayload: String) {
        guard let message = parse(eventPayload: eventPayload) else { return }

        if message.isKeepAlive {
            continuations.values.forEach { $0.yield(.didReceiveKeepAlive) }
            return
        }

        guard endpoint.eventID.rawValue == message.event,
              let data = message.data.data(using: .utf8)
        else { return }

        do {
            if endpoint.decodableType == Data.self {
                continuations.values.forEach { $0.yield(.didReceiveData(data as! E)) }
            } else {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601Flexible
                let result = try decoder.decode(endpoint.decodableType, from: data)
                continuations.values.forEach { $0.yield(.didReceiveData(result)) }
            }
        } catch {
            continuations.values.forEach { $0.yield(.didReceiveError(error.localizedDescription)) }
        }
    }

    /// Returns the next SSE frame boundary, including the full frame length and delimiter length.
    private func nextEventBoundary(in buffer: Data) -> SSEEventBoundary? {
        if let range = buffer.range(of: Data("\r\n\r\n".utf8)) {
            return SSEEventBoundary(
                totalLength: buffer.distance(from: buffer.startIndex, to: range.upperBound),
                delimiterLength: 4
            )
        }

        if let range = buffer.range(of: Data("\n\n".utf8)) {
            return SSEEventBoundary(
                totalLength: buffer.distance(from: buffer.startIndex, to: range.upperBound),
                delimiterLength: 2
            )
        }

        if let range = buffer.range(of: Data("\r\r".utf8)) {
            return SSEEventBoundary(
                totalLength: buffer.distance(from: buffer.startIndex, to: range.upperBound),
                delimiterLength: 2
            )
        }

        return nil
    }

    /// Starts the SSE byte stream against the socket URL and attempts reconnects after non-cancellation failures.
    private func startSSE() {
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

            var buffer = Data() // accumulate partial SSE data

            repeat {
                do {
                    let (bytes, _) = try await URLSession.shared.bytes(from: url)
                    for c in continuations.values {
                        c.yield(.didConnect)
                    }
                    for try await byte in bytes {
                        buffer.append(UInt8(byte))

                        while let boundary = nextEventBoundary(in: buffer) {
                            let eventData = Data(buffer.prefix(boundary.totalLength))
                            buffer.removeFirst(boundary.totalLength)
                            let payloadData = eventData.dropLast(boundary.delimiterLength)

                            guard let eventPayload = String(data: payloadData, encoding: .utf8) else {
                                continue
                            }

                            process(eventPayload: eventPayload)
                        }
                    }

                    // Connection closed normally
                    for c in continuations.values {
                        c.yield(.didDisconnect)
                    }
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
                        for c in continuations.values {
                            c.yield(.didAttemptReconnect)
                        }
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        continue
                    } else {
                        for c in continuations.values {
                            c.yield(.didDisconnect)
                        }
                        break
                    }
                }
            } while true
        }
    }

    /// Cancels the active SSE task and notifies listeners about the disconnect.
    private func stopSSE() {
        task?.cancel()
        task = nil
        taskID = nil
        for continuation in continuations.values {
            continuation.yield(.didDisconnect)
        }
    }
}
