//
//  VTUpdaterConfig.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTUpdaterProvider: String, Codable, Sendable {
    case github = "github"
    case githubNightly = "github_nightly"
}

struct VTUpdaterConfig: Codable, Sendable {
    let updateProvider: VTUpdaterProvider
}
