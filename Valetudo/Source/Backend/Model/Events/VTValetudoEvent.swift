//
//  VTEvent.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation

public protocol VTValetudoEvent: Decodable, Hashable, Equatable, Sendable, Describable {
    var __class: String { get }
    var metaData: [String: VTAnyCodable] { get }
    var id: String { get }
    var timestamp: Date { get }
    var processed: Bool { get }
}

public struct VTConsumableDepletedEvent: VTValetudoEvent {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let id: String
    public let timestamp: Date
    public let processed: Bool
    public let type: VTConsumableType
    public let subType: VTConsumableSubType
    
    public var description: String {
        String(format: "CONSUMABLE_DEPLETED".localized(), type.description, subType.description)
    }
}

public protocol VTDismissibleValetudoEvent: VTValetudoEvent {}

public struct VTDustBinFullEvent: VTDismissibleValetudoEvent {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let id: String
    public let timestamp: Date
    public let processed: Bool
    
    public var description: String {
        "DUST_BIN_FULL".localized()
    }
}


public struct VTErrorStateEvent: VTDismissibleValetudoEvent {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let id: String
    public let timestamp: Date
    public let processed: Bool
    public let message: String
    
    public var description: String {
        message
    }
}

public struct VTMissingResourceEvent: VTDismissibleValetudoEvent {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let id: String
    public let timestamp: Date
    public let processed: Bool
    public let message: String
    
    public var description: String {
        message
    }
}

public struct VTMopAttachmentReminderEvent: VTDismissibleValetudoEvent {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let id: String
    public let timestamp: Date
    public let processed: Bool
    
    public var description: String {
        "MOP_ATTACHMENT_REMINDER".localized()
    }
}

public struct VTPendingMapChangeEvent: VTDismissibleValetudoEvent {
    public let __class: String
    public let metaData: [String: VTAnyCodable]
    public let id: String
    public let timestamp: Date
    public let processed: Bool
    
    public var description: String {
        "PENDING_MAP_CHANGE".localized()
    }
}

public struct VTAnyValetudoEvent: Decodable, Sendable, Hashable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case __class
    }

    let event: any VTValetudoEvent
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let className = try container.decode(String.self, forKey: .__class)

        event = switch className {
        case "ConsumableDepletedValetudoEvent":    try VTConsumableDepletedEvent(from: decoder)
        case "DustBinFullValetudoEvent":           try VTDustBinFullEvent(from: decoder)
        case "ErrorStateValetudoEvent":            try VTErrorStateEvent(from: decoder)
        case "MissingResourceValetudoEvent":       try VTMissingResourceEvent(from: decoder)
        case "MopAttachmentReminderValetudoEvent": try VTMopAttachmentReminderEvent(from: decoder)
        case "PendingMapChangeValetudoEvent":      try VTPendingMapChangeEvent(from: decoder)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .__class,
                in: container,
                debugDescription: "Unknown VTEvent type: \(className)"
            )
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        event.hash(into: &hasher)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.event, rhs.event) {
        case (let this as VTConsumableDepletedEvent, let other as VTConsumableDepletedEvent):       this == other
        case (let this as VTDustBinFullEvent, let other as VTDustBinFullEvent):                     this == other
        case (let this as VTErrorStateEvent, let other as VTErrorStateEvent):                       this == other
        case (let this as VTMissingResourceEvent, let other as VTMissingResourceEvent):             this == other
        case (let this as VTMopAttachmentReminderEvent, let other as VTMopAttachmentReminderEvent): this == other
        case (let this as VTPendingMapChangeEvent, let other as VTPendingMapChangeEvent):           this == other
        case (_, _): false
        }
    }
}
