//
//  VTStateAttribute.swift
//  Valetudo
//
//  Created by David Klopp on 18.05.25.
//

import Foundation

public enum VTPresetType: String, Codable, Sendable {
    case fanSpeed = "fan_speed"
    case waterGrade = "water_grade"
    case operationMode = "operation_mode"
    
    var description: String {
        switch (self) {
        case .waterGrade:       "WATER_GRADE".localized()
        case .fanSpeed:         "FAN_SPEED".localized()
        case .operationMode:    "OPERATION_MODE".localized()
        }
    }
}

public enum VTPresetValue: String, Codable, Sendable {
    case off, min, low, medium, high, max, turbo, custom
    case vacuum, mop, vacuumAndMop = "vacuum_and_mop", vacuumThenMop = "vacuum_then_mop"
    
    var description: String {
        switch self {
        case .off:             "OFF".localized()
        case .min:             "MIN".localized()
        case .low:             "LOW".localized()
        case .medium:          "MEDIUM".localized()
        case .high:            "HIGH".localized()
        case .max:             "MAX".localized()
        case .turbo:           "TURBO".localized()
        case .custom:          "CUSTOM".localized()
        case .vacuum:          "VACUUM".localized()
        case .mop:             "MOP".localized()
        case .vacuumAndMop:    "VACUUM_AND_MOP".localized()
        case .vacuumThenMop:   "VACUUM_THEN_MOP".localized()
        }
    }
}

public enum VTStatusValue: String, Codable, Sendable {
    case docked, error, idle, returning, cleaning, paused, manualControl = "manual_control", moving
    
    var description: String {
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

public enum VTDockStatusValue: String, Codable, Sendable {
    case error, idle, pause, emptying, cleaning, drying
    
    var description: String {
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

public enum VTConsumableUnit: String, Codable, Sendable {
    case percent, minutes
}

public enum VTConsumableType: String, Codable, Sendable {
    case brush, filter, cleaning, mop, detergent
    
    var description: String {
        switch(self) {
        case .brush:        return "BRUSH".localized()
        case .cleaning:     return "CLEANING".localized()
        case .detergent:    return "DETERGENT".localized()
        case .filter:       return "FILTER".localized()
        case .mop:          return "MOP".localized()
        }
    }
}

public enum VTConsumableSubType: String, Codable, Sendable {
    case main, sideRight = "side_right", sensor, all, dock
    
    var description: String {
        switch(self) {
        case .all:          "ALL".localized()
        case .dock:         "DOCK".localized()
        case .main:         "MAIN".localized()
        case .sensor:       "SENSOR".localized()
        case .sideRight:    "RIGHT".localized()
        }
    }
}

public enum VTAttachmentType: String, Codable, Sendable {
    case dustbin, watertank, mop
    
    var description: String {
        switch self {
        case .dustbin:      "DUSTBIN".localized()
        case .watertank:    "WATERTANK".localized()
        case .mop:          "MOP".localized()
        }
    }
}

public enum VTBatteryFlag: String, Codable, Sendable {
    case none, charging, discharging, charged
}

public protocol VTStateAttribute: Decodable, Equatable, Sendable  {
    var __class: String { get }
    var metaData: [String: VTAnyDecodable] { get }
}

extension VTStateAttribute {
  func isEqual(to other: any VTStateAttribute) -> Bool {
    guard let otherSame = other as? Self else { return false }
    return self == otherSame
  }
}

public struct VTAttachmentStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let type: VTAttachmentType
    public let attached: Bool
}

extension VTAttachmentStateAttribute: Equatable {}

public struct VTDockStatusStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let value: VTDockStatusValue
}

extension VTDockStatusStateAttribute: Equatable {}

public struct VTPresetSelectionStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let type: VTPresetType
    public let value: VTPresetValue
    public let customValue: Double?
}

extension VTPresetSelectionStateAttribute: Equatable {}

public struct VTBatteryStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let level: Double
    public let flag: VTBatteryFlag
}

extension VTBatteryStateAttribute: Equatable {}

public struct VTStatusStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let value: VTStatusValue?
    public let flag: VTStatusFlag?
}

extension VTStatusStateAttribute: Equatable {}

public struct VTConsumableRemaining: Codable, Sendable {
    public let value: Double
    public let unit: VTConsumableUnit
    
    var description: String {
        switch (unit) {
        case .percent: 
            return "\(Int(value)) %"
        case .minutes:
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = [.pad]
            return formatter.string(from: DateComponents(minute: Int(value))) ?? ""
        }
    }
}

extension VTConsumableRemaining: Equatable {}

public struct VTConsumableStateAttribute: VTStateAttribute {
    public let __class: String
    public let metaData: [String: VTAnyDecodable]
    public let type: VTConsumableType
    public let subType: VTConsumableSubType
    public let remaining: VTConsumableRemaining
}

extension VTConsumableStateAttribute: Equatable {}


public struct VTConsumableStateAttributeProperties: Decodable, Sendable, Equatable {
    public let type: VTConsumableType
    public let subType: VTConsumableSubType
    public let unit: VTConsumableUnit
    public let maxValue: Double?
}

public struct VTConsumableStateAttributePropertiesList: Decodable, Sendable, Equatable {
    public let availableConsumables: [VTConsumableStateAttributeProperties]
}

public struct VTStateAttributeList: Decodable, Sendable {
    public let attributes: [any VTStateAttribute]
    
    public var dockStatusStateAttributes: [VTDockStatusStateAttribute] {
        attributes.compactMap {
            if ($0.__class == "DockStatusStateAttribute") {
                $0 as? VTDockStatusStateAttribute
            } else {
                nil
            }
        }
    }
    
    public var attachmentStateAttributes: [VTAttachmentStateAttribute] {
        attributes.compactMap {
            if ($0.__class == "AttachmentStateAttribute") {
                $0 as? VTAttachmentStateAttribute
            } else {
                nil
            }
        }
    }
    
    public var presetSelectionStateAttributes: [VTPresetSelectionStateAttribute] {
        attributes.compactMap {
            if ($0.__class == "PresetSelectionStateAttribute") {
                $0 as? VTPresetSelectionStateAttribute
            } else {
                nil
            }
        }
    }
    
    public var batteryStateAttributes: [VTBatteryStateAttribute] {
        attributes.compactMap {
            if ($0.__class == "BatteryStateAttribute") {
                $0 as? VTBatteryStateAttribute
            } else {
                nil
            }
        }
    }
    
    public var statusStateAttributes: [VTStatusStateAttribute] {
        attributes.compactMap {
            if ($0.__class == "StatusStateAttribute") {
                $0 as? VTStatusStateAttribute
            } else {
                nil
            }
        }
    }
    
    public var consumableStateAttributes: [VTConsumableStateAttribute] {
        attributes.compactMap {
            if ($0.__class == "ConsumableStateAttribute") {
                $0 as? VTConsumableStateAttribute
            } else {
                nil
            }
        }
    }
    
    // MARK: - AttachmentStateAttributes
    
    public var attachmendTypes: [VTAttachmentType] {
        return attachmentStateAttributes.map { $0.type }
    }
    
    public var mopPadsAreAttached: Bool {
        return attachmentStateAttributes.first(where: { $0.type == .mop })?.attached ?? false
    }
    
    // MARK: - BatteryStateAttributes
    
    public var batterLevel: Double {
        return batteryStateAttributes.first?.level ?? 100.0
    }
    
    // MARK: - DockStatusStateAttribute
    
    public var isDryingMopPads: Bool {
        return dockStatusStateAttributes.first?.value == .drying
    }
    
    public var isCleaningMopPads: Bool {
        return dockStatusStateAttributes.first?.value == .cleaning
    }
    
    public var isEmptyingIntoDock: Bool {
        return dockStatusStateAttributes.first?.value == .emptying
    }
    
    public var dockIsReady: Bool {
        guard let dockState = dockStatusStateAttributes.first?.value else { return false }
        return (dockState == .idle) || (dockState == .pause)
    }
    
    // MARK: - StatusStateAttributes
    
    public var statusState: VTStatusValue {
        return statusStateAttributes.first?.value ?? .docked
    }
    
    public var isPaused: Bool {
        return statusStateAttributes.first?.value?.isPaused ?? false
    }
    
    public var isStarted: Bool {
        return statusStateAttributes.first?.value?.isStarted ?? false
    }
    
    public var isStoppable: Bool {
        guard let state = statusStateAttributes.first?.value else { return false }
        return (state != .idle && state != .docked) && !self.isResumable
    }
    
    public var canReturnHome: Bool {
        return statusStateAttributes.first?.value?.canReturnHome ?? false
    }
    
    public var isResumable: Bool {
        return statusStateAttributes.first?.flag == .resumable
    }
    
    public var isDocked: Bool {
        guard let state = statusStateAttributes.first?.value else { return false }
        return state == .docked
    }
    
    // MARK: - PresetSelectionStateAttributes
    
    public var fanSpeed: VTPresetValue {
        return self.presetSelectionStateAttributes.first(where: {
            $0.type == .fanSpeed
        })?.value ?? .low
    }
    
    public var waterGrade: VTPresetValue {
        return self.presetSelectionStateAttributes.first(where: {
            $0.type == .waterGrade
        })?.value ?? .low
    }
    
    public var operationMode: VTPresetValue {
        return self.presetSelectionStateAttributes.first(where: {
            $0.type == .operationMode
        })?.value ?? .vacuum
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawArray = try container.decode([[String: VTAnyDecodable]].self)

        var decodedAttributes: [any VTStateAttribute] = []
        let jsonDecoder = JSONDecoder()
        
        for dict in rawArray {
            guard let className = dict["__class"]?.stringValue else { continue }

            // Convert back to Data for decoding the specific type
            let jsonData = try JSONSerialization.data(withJSONObject: dict.mapValues { $0.value })

            switch className {
            case "AttachmentStateAttribute":
                decodedAttributes.append(try jsonDecoder.decode(VTAttachmentStateAttribute.self, from: jsonData))
            case "DockStatusStateAttribute":
                decodedAttributes.append(try jsonDecoder.decode(VTDockStatusStateAttribute.self, from: jsonData))
            case "PresetSelectionStateAttribute":
                decodedAttributes.append(try jsonDecoder.decode(VTPresetSelectionStateAttribute.self, from: jsonData))
            case "BatteryStateAttribute":
                decodedAttributes.append(try jsonDecoder.decode(VTBatteryStateAttribute.self, from: jsonData))
            case "StatusStateAttribute":
                decodedAttributes.append(try jsonDecoder.decode(VTStatusStateAttribute.self, from: jsonData))
            case "ConsumableStateAttribute":
                decodedAttributes.append(try jsonDecoder.decode(VTConsumableStateAttribute.self, from: jsonData))
            default:
                print("Unknown __class: \(className)")
                continue
            }
        }

        self.attributes = decodedAttributes
    }
}

extension VTStateAttributeList: Equatable {
    public static func == (lhs: VTStateAttributeList, rhs: VTStateAttributeList) -> Bool {
        zip(lhs.attributes, rhs.attributes).allSatisfy { $0.0.isEqual(to: $0.1) }
    }
}
