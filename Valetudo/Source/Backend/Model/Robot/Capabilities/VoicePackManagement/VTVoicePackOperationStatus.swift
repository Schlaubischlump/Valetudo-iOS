//
//  VTVoicePackOperationStatus.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

struct VTVoicePackOperationStatus: Codable, Hashable {
    enum OperationType: String, Codable, Hashable {
        case idle
        case downloading
        case installing
        case error
    }

    let type: OperationType
    let progress: Int?
    let metaData: [String: VTAnyCodable]
}
