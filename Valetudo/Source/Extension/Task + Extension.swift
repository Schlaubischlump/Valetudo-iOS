//
//  Task + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import Foundation

actor SerialTaskQueue {
    private var operations: [() async -> Void] = []
    private var isProcessing = false

    func enqueue(_ operation: @Sendable @escaping () async -> Void) async {
        operations.append(operation)
        if !isProcessing {
            isProcessing = true
            Task {
                await self.processNext()
            }
        }
    }

    private func processNext() async {
        while !operations.isEmpty {
            let op = operations.removeFirst()
            await op()
        }
        isProcessing = false
    }
}

func printCurrentQueue() {
    print("Queue label: \(String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) ?? "unknown")")
}

