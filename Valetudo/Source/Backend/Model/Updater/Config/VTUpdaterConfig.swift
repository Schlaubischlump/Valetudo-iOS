//
//  VTUpdaterConfig.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTUpdaterProvider: String, Codable, Sendable, CaseIterable, Describable {
    case github = "github"
    case githubNightly = "github_nightly"
    
    var description: String {
        switch (self) {
        case .github:        "RELEASE".localizedCapitalized()
        case .githubNightly: "NIGHTLY".localizedCapitalized()
        }
    }
}

struct VTUpdaterConfig: Codable, Sendable {
    let updateProvider: VTUpdaterProvider
}
