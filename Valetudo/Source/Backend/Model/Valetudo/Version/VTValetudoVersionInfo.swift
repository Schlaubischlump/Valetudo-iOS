//
//  VTValetudoVersionInfo.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

struct VTValetudoVersionInfo: Decodable, Sendable {
    let release: String
    let commit: String
}
