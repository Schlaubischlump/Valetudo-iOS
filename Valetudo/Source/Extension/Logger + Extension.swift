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
    case sse
    case event
}

func log(message: String, forSubsystem subsystem: VTSubsystem, level: OSLogType = .info) {
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "de.schlaubi.valetudo",
        category: subsystem.rawValue
    )
    logger.log(level: level, "\(message, privacy: .public)")
}
