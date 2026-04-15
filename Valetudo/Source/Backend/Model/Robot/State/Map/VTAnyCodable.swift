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
        return switch self {
        case .bool(let b): b
        default: nil
        }
    }

    public var stringValue: String? {
        return switch self {
        case .string(let s): s
        default: nil
        }
    }

    public var intValue: Int? {
        return switch self {
        case .int(let i): i
        default: nil
        }
    }

    public var doubleValue: Double? {
        return switch self {
        case .double(let d): d
        case .int(let i): Double(i)
        default: nil
        }
    }

    public var arrayValue: [VTAnyCodable]? {
        return switch self {
        case .array(let a): a
        default: nil
        }
    }

    public var dictionaryValue: [String: VTAnyCodable]? {
        return switch self {
        case .dict(let d): d
        default: nil
        }
    }
    
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
        case .int(let i): try container.encode(i)
        case .double(let d): try container.encode(d)
        case .bool(let b): try container.encode(b)
        case .string(let s): try container.encode(s)
        case .null: try container.encodeNil()
        case .array(let arr): try container.encode(arr)
        case .dict(let dict): try container.encode(dict)
        }
    }
}
