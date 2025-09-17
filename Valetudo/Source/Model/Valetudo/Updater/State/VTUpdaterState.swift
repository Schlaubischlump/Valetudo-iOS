//
//  VTUpdaterState.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTUpdaterErrorType: String, Encodable, Sendable {
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

struct VTUpdaterState: Encodable, Sendable {
    let className: String
    let metaData: [String: String]?
    let timestamp: Date
    
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
    }
}
