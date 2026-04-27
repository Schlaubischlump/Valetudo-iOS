//
//  VTEventInteraction.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation

public enum VTEventInteraction: String, Encodable, Hashable, Equatable, Sendable {
    case ok
    case yes
    case no
    case reset
}

struct VTEventInteractionAction: Encodable, Hashable, Equatable {
    let interaction: VTEventInteraction
}
