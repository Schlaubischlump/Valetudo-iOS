//
//  VTStateAttributeList.swift
//  Valetudo
//
//  Created by David Klopp on 18.05.25.
//

import Foundation

public enum VTStatusValue: String, Codable, Sendable, Describable {
    case docked, error, idle, returning, cleaning, paused, manualControl = "manual_control", moving

    public var description: String {
        switch self {
        case .docked: "DOCKED".localized()
        case .cleaning: "CLEANING".localized()
        case .error: "ERROR".localized()
        case .idle: "IDLE".localized()
        case .returning: "RETURNING".localized()
        case .paused: "PAUSED".localized()
        case .manualControl: "MANUAL_CONTROL".localized()
        case .moving: "MOVING".localized()
        }
    }

    var isStarted: Bool {
        switch self {
        case .cleaning, .returning, .moving: true
        default: false
        }
    }

    var isPaused: Bool {
        switch self {
        case .idle, .docked, .paused, .error: true
        default: false
        }
    }

    var canReturnHome: Bool {
        switch self {
        case .idle, .error, .paused: true
        default: false
        }
    }
}

public enum VTStatusFlag: String, Codable, Sendable {
    case none, zone, segment, spot, target, resumable, mapping
}

public enum VTDockStatusValue: String, Codable, Sendable, Describable {
    case error, idle, pause, emptying, cleaning, drying

    public var description: String {
        switch self {
        case .error: "ERROR".localized()
        case .idle: "IDLE".localized()
        case .pause: "PAUSE".localized()
        case .emptying: "EMPTYING".localized()
        case .cleaning: "CLEANING".localized()
        case .drying: "DRYING".localized()
        }
    }
}

public enum VTDockComponentType: Codable, Sendable, Hashable, Describable {
    case cleanWaterTank
    case dirtyWaterTank
    case dustbag
    case detergent
    case unknown(String)

    private init(rawValue: String) {
        self = switch rawValue {
        case "water_tank_clean": .cleanWaterTank
        case "water_tank_dirty": .dirtyWaterTank
        case "dustbag": .dustbag
        case "detergent": .detergent
        default: .unknown(rawValue)
        }
    }

    public var description: String {
        switch self {
        case .cleanWaterTank: "DOCK_COMPONENT_CLEAN_WATER_TANK".localized()
        case .dirtyWaterTank: "DOCK_COMPONENT_DIRTY_WATER_TANK".localized()
        case .dustbag: "DUSTBAG".localized()
        case .detergent: "DETERGENT".localized()
        case let .unknown(value): value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(rawValue: container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = switch self {
        case .cleanWaterTank: "water_tank_clean"
        case .dirtyWaterTank: "water_tank_dirty"
        case .dustbag: "dustbag"
        case .detergent: "detergent"
        case let .unknown(value): value
        }
        try container.encode(value)
    }
}

public enum VTDockComponentValue: Codable, Sendable, Hashable, Describable {
    case ok
    case missing
    case empty
    case full
    case unknown(String)

    private init(rawValue: String) {
        self = switch rawValue {
        case "ok": .ok
        case "missing": .missing
        case "empty": .empty
        case "full": .full
        case "unknown": .unknown(rawValue)
        default: .unknown(rawValue)
        }
    }

    public var description: String {
        switch self {
        case .ok: "OK".localized()
        case .missing: "MISSING".localized()
        case .empty: "EMPTY".localized()
        case .full: "FULL".localized()
        case .unknown: "UNKNOWN".localized()
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(rawValue: container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = switch self {
        case .ok: "ok"
        case .missing: "missing"
        case .empty: "empty"
        case .full: "full"
        case let .unknown(value): value
        }
        try container.encode(value)
    }
}

public enum VTAttachmentType: String, Codable, Sendable, Describable {
    case dustbin, watertank, mop

    public var description: String {
        switch self {
        case .dustbin: "DUSTBIN".localized()
        case .watertank: "WATERTANK".localized()
        case .mop: "MOP".localized()
        }
    }
}

public enum VTBatteryFlag: String, Codable, Sendable {
    case none, charging, discharging, charged
}

public protocol VTStateAttribute: Decodable, Equatable, Sendable {
    var __class: String { get }
    var metaData: [String: VTAnyCodable] { get }
}

extension VTStateAttribute {
    func isEqual(to other: any VTStateAttribute) -> Bool {
        guard let otherSame = other as? Self else { return false }
        return self == otherSame
    }
}

public struct VTAttachmentStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let type: VTAttachmentType
    public let attached: Bool
}

extension VTAttachmentStateAttribute: Equatable {}

public struct VTDockStatusStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let value: VTDockStatusValue
}

extension VTDockStatusStateAttribute: Equatable {}

public struct VTDockComponentStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let type: VTDockComponentType
    public let value: VTDockComponentValue
}

extension VTDockComponentStateAttribute: Equatable {}

public struct VTPresetSelectionStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let type: VTPresetType
    public let value: VTPresetValue
    public let customValue: Double?
}

extension VTPresetSelectionStateAttribute: Equatable {}

public struct VTBatteryStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let level: Double
    public let flag: VTBatteryFlag
}

extension VTBatteryStateAttribute: Equatable {}

public struct VTStatusStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let value: VTStatusValue?
    public let flag: VTStatusFlag?
}

extension VTStatusStateAttribute: Equatable {}

extension VTAnyCodable {
    static let attachmentStateAttribute: VTAnyCodable = .string("AttachmentStateAttribute")
    static let dockStatusStateAttribute: VTAnyCodable = .string("DockStatusStateAttribute")
    static let dockComponentStateAttribute: VTAnyCodable = .string("DockComponentStateAttribute")
    static let presetSelectionStateAttribute: VTAnyCodable = .string("PresetSelectionStateAttribute")
    static let batteryStateAttribute: VTAnyCodable = .string("BatteryStateAttribute")
    static let statusStateAttribute: VTAnyCodable = .string("StatusStateAttribute")
}

/// Since, Valetudo 2025.10.0: Consumables are no longer state attributes
/// This is just here for possible backwards compatibility.
extension VTAnyCodable {
    static let consumableStateAttribute: VTAnyCodable = .string("ConsumableStateAttribute")
    static let valetudoConsumable: VTAnyCodable = .string("ValetudoConsumable")
}

extension VTConsumableState: VTStateAttribute {}

public struct VTStateAttributeList: Decodable, Sendable {
    public let attributes: [any VTStateAttribute]

    public var dockStatusStateAttributes: [VTDockStatusStateAttribute] {
        attributes.compactMap {
            if $0.__class == "DockStatusStateAttribute" {
                $0 as? VTDockStatusStateAttribute
            } else {
                nil
            }
        }
    }

    public var dockComponentStateAttributes: [VTDockComponentStateAttribute] {
        attributes.compactMap {
            if $0.__class == "DockComponentStateAttribute" {
                $0 as? VTDockComponentStateAttribute
            } else {
                nil
            }
        }
    }

    public var attachmentStateAttributes: [VTAttachmentStateAttribute] {
        attributes.compactMap {
            if $0.__class == "AttachmentStateAttribute" {
                $0 as? VTAttachmentStateAttribute
            } else {
                nil
            }
        }
    }

    public var presetSelectionStateAttributes: [VTPresetSelectionStateAttribute] {
        attributes.compactMap {
            if $0.__class == "PresetSelectionStateAttribute" {
                $0 as? VTPresetSelectionStateAttribute
            } else {
                nil
            }
        }
    }

    public var batteryStateAttributes: [VTBatteryStateAttribute] {
        attributes.compactMap {
            if $0.__class == "BatteryStateAttribute" {
                $0 as? VTBatteryStateAttribute
            } else {
                nil
            }
        }
    }

    public var statusStateAttributes: [VTStatusStateAttribute] {
        attributes.compactMap {
            if $0.__class == "StatusStateAttribute" {
                $0 as? VTStatusStateAttribute
            } else {
                nil
            }
        }
    }

    /*
     // Valetudo 2025.10.0: Consumables are no longer state attributes
     public var consumableStateAttributes: [VTConsumableStateAttribute] {
         attributes.compactMap {
             if ($0.__class == "ConsumableStateAttribute") {
                 $0 as? VTConsumableStateAttribute
             } else {
                 nil
             }
         }
     }
     */

    // MARK: - AttachmentStateAttributes

    public var attachmendTypes: [VTAttachmentType] {
        attachmentStateAttributes.map(\.type)
    }

    public var mopPadsAreAttached: Bool {
        attachmentStateAttributes.first(where: { $0.type == .mop })?.attached ?? false
    }

    // MARK: - BatteryStateAttributes

    public var batterLevel: Double {
        batteryStateAttributes.first?.level ?? 100.0
    }

    // MARK: - DockStatusStateAttribute

    public var isDryingMopPads: Bool {
        dockStatusStateAttributes.first?.value == .drying
    }

    public var isCleaningMopPads: Bool {
        dockStatusStateAttributes.first?.value == .cleaning
    }

    public var isEmptyingIntoDock: Bool {
        dockStatusStateAttributes.first?.value == .emptying
    }

    public var dockIsReady: Bool {
        guard let dockState = dockStatusStateAttributes.first?.value else { return false }
        return (dockState == .idle) || (dockState == .pause)
    }

    // MARK: - StatusStateAttributes

    public var statusFlag: VTStatusFlag? {
        statusStateAttributes.first?.flag
    }

    public var statusState: VTStatusValue {
        statusStateAttributes.first?.value ?? .docked
    }

    public var isPaused: Bool {
        statusStateAttributes.first?.value?.isPaused ?? false
    }

    public var isStarted: Bool {
        statusStateAttributes.first?.value?.isStarted ?? false
    }

    public var isStoppable: Bool {
        guard let state = statusStateAttributes.first?.value else { return false }
        return (state != .idle && state != .docked) && !isResumable
    }

    public var canReturnHome: Bool {
        statusStateAttributes.first?.value?.canReturnHome ?? false
    }

    public var isResumable: Bool {
        statusStateAttributes.first?.flag == .resumable
    }

    public var isDocked: Bool {
        guard let state = statusStateAttributes.first?.value else { return false }
        return state == .docked
    }

    // MARK: - PresetSelectionStateAttributes

    public var fanSpeed: VTPresetValue {
        presetSelectionStateAttributes.first(where: {
            $0.type == .fanSpeed
        })?.value ?? .low
    }

    public var waterGrade: VTPresetValue {
        presetSelectionStateAttributes.first(where: {
            $0.type == .waterGrade
        })?.value ?? .low
    }

    public var operationMode: VTPresetValue {
        presetSelectionStateAttributes.first(where: {
            $0.type == .operationMode
        })?.value ?? .vacuum
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawArray = try container.decode([[String: VTAnyCodable]].self)

        var decodedAttributes: [any VTStateAttribute] = []
        let jsonDecoder = JSONDecoder()

        for dict in rawArray {
            guard let className = dict["__class"] else { continue }

            // Convert back to Data for decoding the specific type
            let jsonData = try JSONEncoder().encode(dict)

            switch className {
            case .attachmentStateAttribute:
                try decodedAttributes.append(jsonDecoder.decode(VTAttachmentStateAttribute.self, from: jsonData))
            case .dockStatusStateAttribute:
                try decodedAttributes.append(jsonDecoder.decode(VTDockStatusStateAttribute.self, from: jsonData))
            case .dockComponentStateAttribute:
                try decodedAttributes.append(jsonDecoder.decode(VTDockComponentStateAttribute.self, from: jsonData))
            case .presetSelectionStateAttribute:
                try decodedAttributes.append(jsonDecoder.decode(VTPresetSelectionStateAttribute.self, from: jsonData))
            case .batteryStateAttribute:
                try decodedAttributes.append(jsonDecoder.decode(VTBatteryStateAttribute.self, from: jsonData))
            case .statusStateAttribute:
                try decodedAttributes.append(jsonDecoder.decode(VTStatusStateAttribute.self, from: jsonData))
            case .consumableStateAttribute, .valetudoConsumable:
                try decodedAttributes.append(jsonDecoder.decode(VTConsumableState.self, from: jsonData))
            default:
                log(message: "Unknown __class: \(className)", forSubsystem: .stateAttribute, level: .error)
                continue
            }
        }

        attributes = decodedAttributes
    }
}

extension VTStateAttributeList: Equatable {
    public static func == (lhs: VTStateAttributeList, rhs: VTStateAttributeList) -> Bool {
        lhs.attributes.count == rhs.attributes.count &&
            zip(lhs.attributes, rhs.attributes).allSatisfy { $0.0.isEqual(to: $0.1) }
    }
}
