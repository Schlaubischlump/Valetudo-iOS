//
//  Logger.swift
//  Valetudo
//
//  Created by David Klopp on 28.05.25.
//
import Foundation
import os.log

enum VTSubsystem: String {
    case mock
    // case sse
    case consumable
    case valetudoLog
    case map
    case mapOptions
    case robotControl
    case timer
    case valetudoEvent

    case stateAttribute
}

/// Persists app log output into a shareable file while keeping only the newest content.
final class VTLogFileStore: @unchecked Sendable {
    /// Shared singleton used by the global `log` helper.
    static let shared = VTLogFileStore()

    private static let maximumFileSizeInBytes = 5 * 1024 * 1024

    private let queue = DispatchQueue(label: "de.schlaubi.valetudo.log-file-store")
    private let fileManager = FileManager.default
    private let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// File URL used to store the rolling application log.
    let fileURL: URL

    /// Creates the rolling log store and prepares the log-file location.
    private init() {
        let logsDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Logs", isDirectory: true)
        fileURL = (logsDirectory ?? fileManager.temporaryDirectory)
            .appendingPathComponent("valetudo.log")
    }

    /// Appends a formatted log line and trims older content when the file exceeds 5 MB.
    func append(message: String, subsystem: VTSubsystem, level: OSLogType) {
        let timestamp = formatter.string(from: Date())
        let line = "[\(timestamp)] [\(level.fileDescription)] [\(subsystem.rawValue)] \(message)\n"

        queue.async { [weak self] in
            guard let self else { return }

            do {
                try createDirectoryIfNeeded()
                var data = (try? Data(contentsOf: fileURL)) ?? Data()
                data.append(Data(line.utf8))
                if data.count > Self.maximumFileSizeInBytes {
                    data = trim(data, toFit: Self.maximumFileSizeInBytes)
                }
                try data.write(to: fileURL, options: .atomic)
            } catch {
                assertionFailure("Failed to write log file: \(error.localizedDescription)")
            }
        }
    }

    /// Ensures a shareable on-disk log file exists and returns its file URL.
    func shareableFileURL() throws -> URL {
        try queue.sync {
            try self.createDirectoryIfNeeded()
            if !self.fileManager.fileExists(atPath: self.fileURL.path) {
                try Data().write(to: self.fileURL, options: .atomic)
            }
            return self.fileURL
        }
    }

    /// Creates the parent logs directory when needed.
    private func createDirectoryIfNeeded() throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }

    /// Trims the oldest bytes from the log and advances to the next newline when possible.
    private func trim(_ data: Data, toFit maximumSizeInBytes: Int) -> Data {
        guard data.count > maximumSizeInBytes else { return data }

        var trimmedData = Data(data.suffix(maximumSizeInBytes))
        if let firstNewlineIndex = trimmedData.firstIndex(of: 0x0A) {
            let contentStartIndex = trimmedData.index(after: firstNewlineIndex)
            trimmedData = Data(trimmedData[contentStartIndex...])
        }

        return trimmedData
    }
}

private extension OSLogType {
    /// Human-readable label used when writing the rolling log file.
    var fileDescription: String {
        switch self {
        case .debug: "DEBUG"
        case .info: "INFO"
        case .error: "ERROR"
        case .fault: "FAULT"
        default: "DEFAULT"
        }
    }
}

/// Writes a message to the unified logger and the rolling shareable log file.
func log(message: String, forSubsystem subsystem: VTSubsystem, level: OSLogType = .info) {
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "de.schlaubi.valetudo",
        category: subsystem.rawValue
    )
    logger.log(level: level, "\(message, privacy: .public)")
    VTLogFileStore.shared.append(message: message, subsystem: subsystem, level: level)
}
