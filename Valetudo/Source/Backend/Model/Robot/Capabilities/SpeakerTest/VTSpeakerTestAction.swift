//
//  VTSpeakerTestAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTSpeakerTestActionType: String, Encodable, Hashable {
    case playTestSound = "play_test_sound"
}

struct VTSpeakerTestAction: Encodable, Hashable {
    let action: VTSpeakerTestActionType
}
