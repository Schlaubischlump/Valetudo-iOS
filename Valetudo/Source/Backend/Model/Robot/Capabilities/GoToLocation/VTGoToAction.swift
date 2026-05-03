///
///  VTGoToAction.swift
///  Valetudo
///
///  Created by David Klopp on 03.05.26.
///
enum VTGoToActionType: String, Encodable, Hashable {
    case goto
}

struct VTGoToAction: Encodable, Hashable {
    let action: VTGoToActionType = .goto
    let coordinates: VTMapCoordinate
}
