//
//  VTQuirk.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTQuirk: Codable, Sendable, Hashable {
    let id: String
    let options: [String]
    let title: String
    let description: String
    let value: String
}
