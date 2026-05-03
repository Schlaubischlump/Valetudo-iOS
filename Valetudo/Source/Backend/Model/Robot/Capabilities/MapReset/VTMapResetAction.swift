//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTMapResetActionType: String, Encodable, Hashable {
    case reset
}

struct VTMapResetAction: Encodable, Hashable {
    let action: VTMapResetActionType = .reset
}
