//
//  VTEventInteraction.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation

public enum VTEventInteraction: Encodable, Hashable, Equatable, Sendable {
    case ok
    case yes
    case no
    case reset
}

struct VTEventInteractionAction: Encodable, Hashable, Equatable, Sendable {
    let interaction: VTEventInteraction
}
