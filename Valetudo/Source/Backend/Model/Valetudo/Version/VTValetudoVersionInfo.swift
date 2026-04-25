//
//  VTValetudoVersionInfo.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

public struct VTValetudoVersionInfo: Decodable, Sendable {
    let release: String
    let commit: String
}
