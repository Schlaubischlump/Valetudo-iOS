//
//  JSONDecoder + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 22.05.25.
//
import Foundation

extension JSONDecoder.DateDecodingStrategy {
    /// Allows decoding of ISO8601 dates with or without fractional seconds.
    static let iso8601Flexible: JSONDecoder.DateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", // ISO8601 with fractional seconds
            "yyyy-MM-dd'T'HH:mm:ssXXXXX"      // ISO8601 without fractional seconds
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Expected ISO8601 date string with or without fractional seconds."
        )
    }
}
