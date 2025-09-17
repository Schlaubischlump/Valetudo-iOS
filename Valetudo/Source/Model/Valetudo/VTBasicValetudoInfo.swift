//
//  VTBasicValetudoInfo.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

struct VTBasicValetudoInfo: Codable, Sendable {
    let embedded: Bool
    let systemId: String
    let welcomeDialogDismissed: Bool
}
