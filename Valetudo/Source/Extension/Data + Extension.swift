//
//  Data + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import Foundation

extension Data {
    func ipString(addressFamily: Int32, maxLength: Int32) -> String? {
        self.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else { return nil }

            var outputBuffer = [CChar](repeating: 0, count: Int(maxLength))
            guard inet_ntop(addressFamily, baseAddress, &outputBuffer, socklen_t(maxLength)) != nil else {
                return nil
            }
            let stringBytes = outputBuffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
            return String(decoding: stringBytes, as: UTF8.self)
        }
    }
}
