//
//  VTAppSettingsSection.swift
//  Valetudo
//
//  Created by David Klopp on 06.05.26.
//


/// Defines the sections used by the app settings screen.
enum VTAppSettingsSection: Int, CaseIterable {
    case robot
    case map
    case log

    /// Human-readable section header title.
    var title: String {
        switch self {
        case .robot: "ROBOT".localized()
        case .map: "MAP".localized()
        case .log: "LOG".localized()
        }
    }
}