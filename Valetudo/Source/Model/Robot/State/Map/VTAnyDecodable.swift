//
//  VTAnyDecodable.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTAnyDecodable: Decodable, Sendable {
    public let value: any Sendable

    public var boolValue: Bool? { value as? Bool }

    public var stringValue: String? { value as? String }

    public var intValue: Int? { value as? Int }

    public var doubleValue: Double? {
        if let double = value as? Double {
            return double
        } else if let int = value as? Int {
            return Double(int)
        }
        return nil
    }

    public var arrayValue: [VTAnyDecodable]? {
        if let array = value as? [any Sendable] {
            return array.map { VTAnyDecodable(wrapping: $0) }
        }
        return nil
    }

    public var dictionaryValue: [String: VTAnyDecodable]? {
        if let dict = value as? [String: any Sendable] {
            return dict.mapValues { VTAnyDecodable(wrapping: $0) }
        }
        return nil
    }

    private init(wrapping value: any Sendable) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([VTAnyDecodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: VTAnyDecodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
}

extension VTAnyDecodable: Equatable {
    public static func == (lhs: VTAnyDecodable, rhs: VTAnyDecodable) -> Bool {
        return ((lhs.value as? NSObject == NSNull()) && (rhs.value as? NSObject == NSNull()))
            || ((lhs.intValue != nil) && (lhs.intValue == rhs.intValue))
            || ((lhs.stringValue != nil) && (lhs.stringValue == rhs.stringValue))
            || ((lhs.boolValue != nil) && (lhs.boolValue == rhs.boolValue))
            || ((lhs.doubleValue != nil) && (lhs.doubleValue == rhs.doubleValue))
            || ((lhs.arrayValue != nil) && (lhs.arrayValue == rhs.arrayValue))
            || ((lhs.dictionaryValue != nil) && (lhs.dictionaryValue == rhs.dictionaryValue))
    }
}
