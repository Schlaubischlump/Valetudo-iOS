///
///  VTKeyLockState.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTLocateRobotActionType: String, Encodable, Hashable {
    case locate
}

struct VTLocateRobotAction: Encodable, Hashable {
    let action: VTLocateRobotActionType
}
