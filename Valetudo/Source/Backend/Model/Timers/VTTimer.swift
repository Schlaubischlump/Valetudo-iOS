//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 07.10.25.
//
import Foundation

public struct VTTimer: Encodable, Decodable, Equatable, Sendable, Hashable {
    public struct Action: Codable, Equatable, Sendable, Hashable {
        public let type: ActionType
        public let params: Params

        public static let fullCleanup = Action(type: .fullCleanup, params: .empty)
        public static let segmentedCleanup = Action(type: .segmentCleanup, params: .empty)

        public enum ActionType: String, CaseIterable, Codable, Sendable, Hashable, Describable {
            case fullCleanup = "full_cleanup"
            case segmentCleanup = "segment_cleanup"

            public var description: String {
                switch self {
                case .fullCleanup: "FULL_CLEANUP".localized()
                case .segmentCleanup: "SEGMENT_CLEANUP".localized()
                }
            }
        }

        public struct Params: Codable, Equatable, Sendable, Hashable {
            public let zoneId: String?
            public let segmentIds: [String]?
            public let gotoId: String?
            public let iterations: Int?
            public let customOrder: Bool?

            public static let empty = Params(zoneId: nil, segmentIds: nil, gotoId: nil, iterations: nil, customOrder: nil)

            private enum CodingKeys: String, CodingKey {
                case zoneId = "zone_id"
                case segmentIds = "segment_ids"
                case gotoId = "goto_id"
                case iterations
                case customOrder = "custom_order"
            }

            public func copy(segmentIds: [String], iterations: Int, customOrder: Bool) -> Params {
                Params(
                    zoneId: zoneId,
                    segmentIds: segmentIds,
                    gotoId: gotoId,
                    iterations: iterations,
                    customOrder: customOrder
                )
            }

            public func copy(customOrder: Bool) -> Params {
                Params(
                    zoneId: zoneId,
                    segmentIds: segmentIds,
                    gotoId: gotoId,
                    iterations: iterations,
                    customOrder: customOrder
                )
            }

            public func copy(iterations: Int) -> Params {
                Params(
                    zoneId: zoneId,
                    segmentIds: segmentIds,
                    gotoId: gotoId,
                    iterations: iterations,
                    customOrder: customOrder
                )
            }

            public func copy(segmentIDs: [String]) -> Params {
                Params(
                    zoneId: zoneId,
                    segmentIds: segmentIDs,
                    gotoId: gotoId,
                    iterations: iterations,
                    customOrder: customOrder
                )
            }
        }
    }

    public struct PreAction: Codable, Equatable, Sendable, Hashable {
        public let type: PreActionType
        public let params: Params

        public enum PreActionType: String, CaseIterable, Codable, Sendable, Hashable {
            case fanSpeedControl = "fan_speed_control"
            case waterUsageControl = "water_usage_control"
            case operationModeControl = "operation_mode_control"
        }

        public struct Params: Codable, Equatable, Sendable, Hashable {
            let value: VTPresetValue?
        }
    }

    public let id: String?
    public let enabled: Bool
    public let label: String
    public let dow: [Int]
    public let hour: Int
    public let minute: Int
    public let action: Action
    public let preActions: [PreAction]
    public let metaData: [String: VTAnyCodable]?

    init() {
        id = nil
        enabled = true
        label = "Timer"
        dow = []
        hour = 9
        minute = 13
        action = .fullCleanup
        preActions = []
        metaData = nil
    }

    init(id: String?,
         enabled: Bool,
         label: String,
         dow: [Int],
         hour: Int,
         minute: Int,
         action: VTTimer.Action,
         preActions: [VTTimer.PreAction],
         metaData: [String: VTAnyCodable]? = nil)
    {
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
        case metaData
    }

    public var weekdays: [VTWeekday] {
        dow.compactMap { VTWeekday(rawValue: $0) }
    }
}

public extension VTTimer {
    func copy(
        enabled: Bool? = nil,
        label: String? = nil,
        dow: [Int]? = nil,
        hour: Int? = nil,
        minute: Int? = nil,
        action: Action? = nil,
        preActions: [PreAction]? = nil,
        metaData: [String: VTAnyCodable]? = nil
    ) -> VTTimer {
        VTTimer(
            id: id,
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
        dow.contains(weekday.index)
    }

    func update(weekday: VTWeekday, enabled: Bool) -> VTTimer {
        if enabled {
            copy(dow: (dow + [weekday.index]).sorted())
        } else {
            copy(dow: dow.filter { $0 != weekday.index })
        }
    }
}
