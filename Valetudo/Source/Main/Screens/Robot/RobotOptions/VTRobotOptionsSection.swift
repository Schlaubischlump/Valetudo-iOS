//
//  VTRobotOptionsSection.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTRobotOptionsSection: Int, CaseIterable {
    case general
    case behavior
    case perception
    case dock
    case misc

    var title: String {
        switch self {
        case .general: "GENERAL".localized()
        case .behavior: "BEHAVIOR".localized()
        case .perception: "PERCEPTION".localized()
        case .dock: "DOCK".localized()
        case .misc: "MISC".localized()
        }
    }
}
