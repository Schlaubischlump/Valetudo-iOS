///
///  VTKeyLockState.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTKeyLockActionType: String, Encodable, Hashable {
    case enable
    case disable
}

struct VTKeyLockAction: Encodable, Hashable {
    let action: VTKeyLockActionType
}
