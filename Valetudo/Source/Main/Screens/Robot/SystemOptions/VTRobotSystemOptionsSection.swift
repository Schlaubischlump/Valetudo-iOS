//
//  VTRobotSystemOptionsSection.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTRobotSystemOptionsSection: Int, CaseIterable {
    case speaker
    /// case voicePacks
    case doNotDisturb

    var title: String {
        switch self {
        case .speaker: "SPEAKER".localized()
        // case .voicePacks: "VOICE_PACKS".localized()
        case .doNotDisturb: "DO_NOT_DISTURB".localized()
        }
    }
}
