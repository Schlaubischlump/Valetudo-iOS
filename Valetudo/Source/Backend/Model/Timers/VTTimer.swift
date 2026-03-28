//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 07.10.25.
//
import Foundation

enum VTWeekday: Int, Codable, Hashable, Sendable {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

struct VTTimer: Decodable, Equatable, Sendable {
    struct Action: Codable, Equatable, Sendable {
        let type: String
        let params: Params

        enum ActionType: String, Codable, Sendable {
            case fullCleanup = "full_cleanup"
            case segmentCleanup = "segment_cleanup"
        }
        
        struct Params: Codable, Equatable, Sendable {
            let zoneId: String?
            let segmentIds: [String]?
            let gotoId: String?
            let iterations: Int?
            let customOrder: Bool?

            private enum CodingKeys: String, CodingKey {
                case zoneId = "zone_id"
                case segmentIds = "segment_ids"
                case gotoId = "goto_id"
                case iterations
                case customOrder = "custom_order"
            }
        }
    }

    struct PreAction: Codable, Equatable, Sendable {
        let type: String
        let params: Params

        struct Params: Codable, Equatable, Sendable {
            let value: String
        }
    }

    let id: String
    let enabled: Bool
    let label: String
    let dow: [Int]
    let hour: Int
    let minute: Int
    let action: Action
    let preActions: [PreAction]
    let metaData: [String: VTAnyDecodable]

    private enum CodingKeys: String, CodingKey {
        case id
        case enabled
        case label
        case dow
        case hour
        case minute
        case action
        case preActions = "pre_actions"
        case metaData = "metaData"
    }
    
    var weekdays: [VTWeekday] {
        dow.compactMap { VTWeekday(rawValue: $0) }
    }
}
