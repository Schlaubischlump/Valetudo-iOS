//
//  VTUpdaterConfig.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

public enum VTUpdaterProvider: String, Codable, Sendable, CaseIterable, Describable {
    case github
    case githubNightly = "github_nightly"

    public var description: String {
        switch self {
        case .github: "RELEASE".localized()
        case .githubNightly: "NIGHTLY".localized()
        }
    }
}

public struct VTUpdaterConfig: Codable, Sendable {
    public let updateProvider: VTUpdaterProvider
}
