//
//  VTVoicePackManagementAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTVoicePackManagementActionType: String, Encodable, Hashable {
    case download
}

struct VTVoicePackManagementAction: Encodable, Hashable {
    let action: VTVoicePackManagementActionType
    let url: String
    let language: String
    let hash: String
}
