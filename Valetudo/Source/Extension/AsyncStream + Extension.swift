//
//  AsyncStream + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 20.04.26.
//
import Foundation

extension AsyncStream {
    func mapStream<T: Sendable>(
        _ transform: @escaping @Sendable (Element) -> T
    ) -> AsyncStream<T> where Element: Sendable {
        AsyncStream<T> { continuation in
            let task = Task {
                for await value in self {
                    continuation.yield(transform(value))
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
