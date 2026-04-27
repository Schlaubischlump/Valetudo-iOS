//
//  VTPollSocket.swift
//  Valetudo
//
//  Created by David Klopp on 19.04.26.
//
import Foundation

/// A shared polling socket for endpoints that are not consumed through SSE.
///
/// `VTPollSocket` owns one polling task per endpoint instance and broadcasts lifecycle and
/// decoded data actions to every registered listener. Polling starts when the first listener is
/// registered and stops when the final listener is removed.
final actor VTPollSocket<E: Decodable & Equatable & Sendable, O: Sendable>: VTEventSocketProtocol {
    typealias Action = VTEventAction<E>

    private var continuations: [VTListenerToken: AsyncStream<Action>.Continuation] = [:]
    private var task: Task<Void, Never>?
    private var taskID: UUID?
    private var lastResult: E?

    let endpoint: VTEventEndpoint<E, O>
    private let url: URL
    private let interval: TimeInterval

    /// Creates a polling socket with the default polling interval.
    init(endpoint: VTEventEndpoint<E, O>, url: URL) {
        self.endpoint = endpoint
        self.url = url
        interval = 5
    }

    /// Creates a polling socket with a custom interval, clamped to a minimum of 0.1 seconds.
    init(endpoint: VTEventEndpoint<E, O>, url: URL, interval: TimeInterval) {
        self.endpoint = endpoint
        self.url = url
        self.interval = max(interval, 0.1)
    }

    /// Registers a listener and starts polling when this is the first active listener.
    func register() -> (VTListenerToken, AsyncStream<Action>) {
        let token = UUID()
        let stream = AsyncStream<Action> { continuation in
            continuations[token] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.remove(token: token) }
            }

            if task == nil {
                startPolling()
            }
        }
        return (token, stream)
    }

    /// Removes a listener and stops polling when no listeners remain.
    func remove(token: VTListenerToken) {
        continuations[token] = nil

        if continuations.isEmpty {
            stopPolling()
        }
    }

    // MARK: - Polling Lifecycle

    /// Starts the polling loop against the socket URL and broadcasts only changed decoded values.
    private func startPolling() {
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

            for c in continuations.values {
                c.yield(.didConnect)
            }

            while !Task.isCancelled, !continuations.isEmpty {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    try validate(response: response)

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601Flexible
                    let result = try decoder.decode(endpoint.decodableType, from: data)

                    if result != lastResult {
                        lastResult = result
                        for c in continuations.values {
                            c.yield(.didReceiveData(result))
                        }
                    }
                } catch is CancellationError {
                    break
                } catch {
                    if Task.isCancelled {
                        break
                    }

                    for c in continuations.values {
                        c.yield(.didReceiveError(error.localizedDescription))
                    }
                }

                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    /// Cancels the active polling task and resets cached polling state.
    private func stopPolling() {
        task?.cancel()
        task = nil
        taskID = nil
        lastResult = nil
        for continuation in continuations.values {
            continuation.yield(.didDisconnect)
        }
    }

    /// Throws when the polling response is not a successful HTTP response.
    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ..< 300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
}
