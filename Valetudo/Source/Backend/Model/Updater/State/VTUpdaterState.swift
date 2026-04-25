//
//  VTUpdaterState.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

public enum VTUpdaterErrorType: String, Decodable, Sendable {
    case unknown
    case not_embedded
    case not_docked
    case not_writable
    case not_enough_space
    case download_failed
    case no_matching_binary
    case missing_manifest
    case invalid_manifest
    case invalid_checksum
}

public protocol VTUpdaterState: Equatable, Sendable {
    var className: String { get }
    var timestamp: Date { get }
    var busy: Bool { get }
    var metaData: [String: VTAnyCodable] { get }
}

public struct VTUpdaterNoUpdateRequiredState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
    
    public let currentVersion: String
    public let changelog: String
}

public struct VTUpdaterIdleState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
    
    public let currentVersion: String
}

public struct VTUpdaterErrorState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
    
    public let type: VTUpdaterErrorType
    public let message: String
}

public struct VTUpdaterDownloadingState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
    
    public let version: String
    public let releaseTimestamp: Date
    public let downloadUrl: String
    public let expectedHash: String
    public let downloadPath: String
    
    public var progress: Double? {
        if let progress = self.metaData["progress"] {
            return progress.doubleValue
        }
        return nil
    }
}

public struct VTUpdaterDisabledState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
}

public struct VTUpdaterApprovalPendingState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
    
    public let version: String
    public let releaseTimestamp: Date
    public let changelog: String
    public let downloadUrl: String
    public let expectedHash: String
    public let downloadPath: String
}

public struct VTUpdaterApplyPendingState: VTUpdaterState, Equatable, Sendable {
    public let className: String
    public let timestamp: Date
    public let busy: Bool
    public let metaData: [String: VTAnyCodable]
    
    public let version: String
    public let releaseTimestamp: Date
    public let downloadPath: String
}

internal struct VTUpdaterStateDecoder: Decodable, Sendable, Equatable {
    let className: String
    let metaData: [String: VTAnyCodable]?
    let timestamp: Date
    var busy: Bool
    
    var stateObject: any VTUpdaterState {
        let metaData = metaData ?? [:]
        switch (self.className) {
        case "ValetudoUpdaterNoUpdateRequiredState":
            return VTUpdaterNoUpdateRequiredState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData,
                currentVersion: currentVersion ?? "",
                changelog: changelog ?? ""
            )
        case "ValetudoUpdaterIdleState":
            return VTUpdaterIdleState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData,
                currentVersion: currentVersion ?? ""
            )
        case "ValetudoUpdaterErrorState":
            return VTUpdaterErrorState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData,
                type: type ?? .unknown,
                message: message ?? ""
            )
        case "ValetudoUpdaterDownloadingState":
            return VTUpdaterDownloadingState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData,
                version: version ?? "",
                releaseTimestamp: releaseTimestamp ?? .distantPast,
                downloadUrl: downloadUrl ?? "",
                expectedHash: expectedHash ?? "",
                downloadPath: downloadPath ?? ""
            )
        case "ValetudoUpdaterDisabledState":
            return VTUpdaterDisabledState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData
            )
        case "ValetudoUpdaterApprovalPendingState":
            return VTUpdaterApprovalPendingState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData,
                version: version ?? "",
                releaseTimestamp: releaseTimestamp ?? .distantPast,
                changelog: changelog ?? "",
                downloadUrl: downloadUrl ?? "",
                expectedHash: expectedHash ?? "",
                downloadPath: downloadPath ?? ""
            )
        case "ValetudoUpdaterApplyPendingState":
            return VTUpdaterApplyPendingState(
                className: className,
                timestamp: timestamp,
                busy: busy,
                metaData: metaData,
                version: version ?? "",
                releaseTimestamp: releaseTimestamp ?? .distantPast,
                downloadPath: downloadPath ?? ""
            )
        default:
            fatalError("Unhandeled updater object.")
        }
    }
    
    // Common fields
    let currentVersion: String?
    
    // Error state
    let type: VTUpdaterErrorType?
    let message: String?
    
    // Downloading / Downloaded / Verifying
    let version: String?
    let releaseTimestamp: Date?
    let changelog: String?
    let downloadUrl: String?
    let expectedHash: String?
    let downloadPath: String?
    
    enum CodingKeys: String, CodingKey {
        case className = "__class"
        case metaData
        case timestamp
        case currentVersion
        case type
        case message
        case version
        case releaseTimestamp
        case changelog
        case downloadUrl
        case expectedHash
        case downloadPath
        case busy
    }
}
