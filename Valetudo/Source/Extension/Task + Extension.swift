//
//  Task + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//

actor SerialTaskQueue {
    private var operations: [() async -> Void] = []
    private var isProcessing = false

    func enqueue(_ operation: @escaping () async -> Void) {
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

