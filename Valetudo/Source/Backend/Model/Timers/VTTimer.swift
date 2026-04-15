//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 07.10.25.
//
import Foundation

struct VTTimer: Encodable, Decodable, Equatable, Sendable, Hashable {
    struct Action: Codable, Equatable, Sendable, Hashable {
        let type: ActionType
        let params: Params
        
        static let fullCleanup = Action(type: .fullCleanup, params: .empty)
        static let segmentedCleanup = Action(type: .segmentCleanup, params: .empty)

        enum ActionType: String, CaseIterable, Codable, Sendable, Hashable, Describable {
            case fullCleanup = "full_cleanup"
            case segmentCleanup = "segment_cleanup"
            
            var description: String {
                return switch (self) {
                case .fullCleanup: "FULL_CLEANUP".localized()
                case .segmentCleanup: "SEGMENT_CLEANUP".localized()
                }
            }
        }
        
        struct Params: Codable, Equatable, Sendable, Hashable {
            let zoneId: String?
            let segmentIds: [String]?
            let gotoId: String?
            let iterations: Int?
            let customOrder: Bool?

            static let empty = Params(zoneId: nil, segmentIds: nil, gotoId: nil, iterations: nil, customOrder: nil)
            
            private enum CodingKeys: String, CodingKey {
                case zoneId = "zone_id"
                case segmentIds = "segment_ids"
                case gotoId = "goto_id"
                case iterations
                case customOrder = "custom_order"
            }
            
            func copy(segmentIds: [String], iterations: Int, customOrder: Bool) -> Params {
                Params(
                    zoneId: self.zoneId,
                    segmentIds: segmentIds,
                    gotoId: self.gotoId,
                    iterations: iterations,
                    customOrder: customOrder,
                )
            }
            
            func copy(customOrder: Bool) -> Params {
                Params(
                    zoneId: self.zoneId,
                    segmentIds: self.segmentIds,
                    gotoId: self.gotoId,
                    iterations: self.iterations,
                    customOrder: customOrder,
                )
            }
            
            func copy(iterations: Int) -> Params {
                Params(
                    zoneId: self.zoneId,
                    segmentIds: self.segmentIds,
                    gotoId: self.gotoId,
                    iterations: iterations,
                    customOrder: self.customOrder,
                )
            }
            
            
            func copy(segmentIDs: [String]) -> Params {
                Params(
                    zoneId: self.zoneId,
                    segmentIds: segmentIDs,
                    gotoId: self.gotoId,
                    iterations: self.iterations,
                    customOrder: self.customOrder,
                )
            }
        }
    }

    struct PreAction: Codable, Equatable, Sendable, Hashable {
        let type: PreActionType
        let params: Params
        
        enum PreActionType: String, CaseIterable, Codable, Sendable, Hashable {
            case fanSpeedControl = "fan_speed_control"
            case waterUsageControl = "water_usage_control"
            case operationModeControl = "operation_mode_control"
        }

        struct Params: Codable, Equatable, Sendable, Hashable {
            let value: VTPresetValue?
        }
    }

    let id: String?
    let enabled: Bool
    let label: String
    let dow: [Int]
    let hour: Int
    let minute: Int
    let action: Action
    let preActions: [PreAction]
    let metaData: [String: VTAnyCodable]?

    init() {
        self.id = nil
        self.enabled = true
        self.label = "Timer"
        self.dow = []
        self.hour = 9
        self.minute = 13
        self.action = .fullCleanup
        self.preActions = []
        self.metaData = nil
    }
    
    init(id: String?,
         enabled: Bool,
         label: String,
         dow: [Int],
         hour: Int,
         minute: Int,
         action: VTTimer.Action,
         preActions: [VTTimer.PreAction],
         metaData: [String : VTAnyCodable]? = nil
    ) {
        self.id = id
        self.enabled = enabled
        self.label = label
        self.dow = dow
        self.hour = hour
        self.minute = minute
        self.action = action
        self.preActions = preActions
        self.metaData = metaData
    }
    
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

extension VTTimer {
    func copy(
        enabled: Bool? = nil,
        label: String? = nil,
        dow: [Int]? = nil,
        hour: Int? = nil,
        minute: Int? = nil,
        action: Action? = nil,
        preActions: [PreAction]? = nil,
        metaData: [String: VTAnyCodable]? = nil,
    ) -> VTTimer {
        VTTimer(
            id: self.id,
            enabled: enabled ?? self.enabled,
            label: label ?? self.label,
            dow: dow ?? self.dow,
            hour: hour ?? self.hour,
            minute: minute ?? self.minute,
            action: action ?? self.action,
            preActions: preActions ?? self.preActions,
            metaData: metaData ?? self.metaData
        )
    }
    
    func isActiveWeekday(_ weekday: VTWeekday) -> Bool {
        self.dow.contains(weekday.index)
    }
    
    func update(weekday: VTWeekday, enabled: Bool) -> VTTimer {
        if enabled {
            copy(dow: (self.dow + [weekday.index]).sorted())
        } else {
            copy(dow: self.dow.filter { $0 != weekday.index })
        }
    }
}
