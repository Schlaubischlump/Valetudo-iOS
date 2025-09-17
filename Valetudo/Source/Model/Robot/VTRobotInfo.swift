//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 18.05.25.
//
import Foundation

enum VTAttachment: String, Decodable, Sendable {
    case dustbin
    case watertank
    case mop
}

struct VTModelDetails: Decodable, Sendable {
    let supportedAttachments: [VTAttachment]
}

public struct VTRobotInfo: Decodable, Sendable {
    let manufacturer: String
    let modelName: String
    let modelDetails: VTModelDetails
    let implementation: String

    var description: String { "\(manufacturer) \(modelName)" }
}
