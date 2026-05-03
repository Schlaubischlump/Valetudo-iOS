//
//  VTMapSnapshotAction.swift
//  Valetudo
//

import Foundation

enum VTMapSnapshotActionType: String, Encodable, Hashable {
    case restore
}

struct VTMapSnapshotAction: Encodable, Hashable {
    let action: VTMapSnapshotActionType
    let id: String
}
