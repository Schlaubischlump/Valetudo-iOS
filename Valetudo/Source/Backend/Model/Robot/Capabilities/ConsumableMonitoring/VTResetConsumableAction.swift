//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTResetConsumableActionType: String, Encodable, Hashable {
    case reset
}

struct VTResetConsumableAction: Encodable, Hashable {
    let action: VTResetConsumableActionType = .reset
}
