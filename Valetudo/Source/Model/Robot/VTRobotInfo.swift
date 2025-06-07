//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 18.05.25.
//
import Foundation

public struct VTRobotInfo: Decodable {
    let manufacturer: String
    let modelName: String
    let modelDetails: ModelDetails
    let implementation: String

    var description: String { "\(manufacturer) \(modelName)" }
    
    struct ModelDetails: Decodable {
        let supportedAttachments: [Attachment]
        
        enum Attachment: String, Decodable {
            case dustbin
            case watertank
            case mop
        }
    }
}
