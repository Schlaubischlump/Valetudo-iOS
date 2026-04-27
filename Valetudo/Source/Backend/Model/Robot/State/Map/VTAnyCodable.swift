//
//  VTAnyDecodable.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public enum VTAnyCodable: Codable, Sendable, Hashable, Equatable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([VTAnyCodable])
    case dict([String: VTAnyCodable])
    case null

    public var boolValue: Bool? {
        switch self {
        case let .bool(b): b
        default: nil
        }
    }

    public var stringValue: String? {
        switch self {
        case let .string(s): s
        default: nil
        }
    }

    public var intValue: Int? {
        switch self {
        case let .int(i): i
        default: nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case let .double(d): d
        case let .int(i): Double(i)
        default: nil
        }
    }

    public var arrayValue: [VTAnyCodable]? {
        switch self {
        case let .array(a): a
        default: nil
        }
    }

    public var dictionaryValue: [String: VTAnyCodable]? {
        switch self {
        case let .dict(d): d
        default: nil
        }
    }

    /// This is a best effort decoding strategy. E.g we might end up decoding a float value as an int or a data value as a string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([VTAnyCodable].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: VTAnyCodable].self) {
            self = .dict(dict)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.typeMismatch(
                VTAnyCodable.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported value type at path"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .int(i): try container.encode(i)
        case let .double(d): try container.encode(d)
        case let .bool(b): try container.encode(b)
        case let .string(s): try container.encode(s)
        case .null: try container.encodeNil()
        case let .array(arr): try container.encode(arr)
        case let .dict(dict): try container.encode(dict)
        }
    }
}
