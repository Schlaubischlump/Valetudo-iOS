//
//  VTVoicePackManagementStatus.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTVoicePackManagementStatus: Codable, Sendable, Hashable {
    let currentLanguage: String
    let operationStatus: VTVoicePackOperationStatus
}
