//
//  VTUpdaterAction.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import Foundation

enum VTUpdaterActionType: String, Encodable, Sendable {
    case check
    case download
    case apply
}

struct VTUpdaterAction: Encodable, Sendable {
    let action: VTUpdaterActionType
}
