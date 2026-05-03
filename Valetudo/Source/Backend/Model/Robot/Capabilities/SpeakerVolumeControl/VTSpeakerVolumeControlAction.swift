//
//  VTSpeakerVolumeControlAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTSpeakerVolumeControlActionType: String, Encodable, Hashable {
    case setVolume = "set_volume"
}

struct VTSpeakerVolumeControlAction: Encodable, Hashable {
    let action: VTSpeakerVolumeControlActionType
    let value: Int
}
