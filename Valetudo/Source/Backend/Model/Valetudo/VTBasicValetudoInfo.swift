//
//  VTBasicValetudoInfo.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

public struct VTBasicValetudoInfo: Decodable, Sendable {
    let embedded: Bool
    let systemId: String
    let welcomeDialogDismissed: Bool
}
