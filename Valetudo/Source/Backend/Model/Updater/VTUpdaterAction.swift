//
//  VTUpdaterAction.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import Foundation

enum VTUpdaterActionType: String, Encodable {
    case check
    case download
    case apply
}

struct VTUpdaterAction: Encodable {
    let action: VTUpdaterActionType
}
