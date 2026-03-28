//
//  LogParser.swift
//  Valetudo
//

import Foundation

/// High-performance log parser using direct pointer manipulation
/// and manual date parsing for maximum speed.
struct VTLogParser {
    
    /// Parses log text into structured log entries.
    /// Uses C-level pointer manipulation for speed.
    static func parse(_ text: String) -> [VTLogLine] {
        guard !text.isEmpty else { return [] }
        
        var results: [VTLogLine] = []
        results.reserveCapacity(1000)
        
        text.withCString { cString in
            var ptr = cString
            var entryStartPtr: UnsafePointer<CChar>? = nil
            
            while ptr.pointee != 0 {
                if ptr.pointee == 0x5B { // '['
                    if looksLikeTimestamp(ptr) {
                        if let start = entryStartPtr {
                            if let logLine = parseLogLine(from: start, to: ptr) {
                                results.append(logLine)
                            }
                        }
                        entryStartPtr = ptr
                    }
                }
                ptr = ptr.advanced(by: 1)
            }
            
            if let start = entryStartPtr {
                if let logLine = parseLogLine(from: start, to: ptr) {
                    results.append(logLine)
                }
            }
        }
        
        results.reverse()
        return results
    }
    
    // MARK: - Private
    
    @inline(__always)
    private static func looksLikeTimestamp(_ ptr: UnsafePointer<CChar>) -> Bool {
        // Check pattern: [YYYY-MM-DDTHH (13 chars after '[')
        let p = ptr.advanced(by: 1)
        return p[0] >= 0x30 && p[0] <= 0x39 &&  // Y
               p[1] >= 0x30 && p[1] <= 0x39 &&  // Y
               p[2] >= 0x30 && p[2] <= 0x39 &&  // Y
               p[3] >= 0x30 && p[3] <= 0x39 &&  // Y
               p[4] == 0x2D &&                   // -
               p[5] >= 0x30 && p[5] <= 0x39 &&  // M
               p[6] >= 0x30 && p[6] <= 0x39 &&  // M
               p[7] == 0x2D &&                   // -
               p[8] >= 0x30 && p[8] <= 0x39 &&  // D
               p[9] >= 0x30 && p[9] <= 0x39 &&  // D
               p[10] == 0x54                     // T
    }
    
    private static func parseLogLine(from start: UnsafePointer<CChar>, to end: UnsafePointer<CChar>) -> VTLogLine? {
        var ptr = start.advanced(by: 1) // skip '['
        
        // Parse timestamp directly to Unix time
        guard let timestamp = parseTimestamp(&ptr) else { return nil }
        
        // Skip past ']' and whitespace
        while ptr < end && ptr.pointee != 0 && ptr.pointee != 0x5D { ptr = ptr.advanced(by: 1) }
        if ptr.pointee == 0x5D { ptr = ptr.advanced(by: 1) }
        while ptr < end && (ptr.pointee == 0x20 || ptr.pointee == 0x09) { ptr = ptr.advanced(by: 1) }
        
        // Parse [LEVEL] if present
        var level = ""
        if ptr < end && ptr.pointee == 0x5B {
            let levelStart = ptr.advanced(by: 1)
            var levelEnd = levelStart
            while levelEnd < end && levelEnd.pointee != 0 && levelEnd.pointee != 0x5D {
                levelEnd = levelEnd.advanced(by: 1)
            }
            if levelEnd.pointee == 0x5D {
                let length = levelStart.distance(to: levelEnd)
                level = stringFromCString(levelStart, length: length)
                ptr = levelEnd.advanced(by: 1)
                while ptr < end && (ptr.pointee == 0x20 || ptr.pointee == 0x09) { ptr = ptr.advanced(by: 1) }
            }
        }
        
        // Extract message
        let message = extractMessage(from: ptr, to: end)
        
        return VTLogLine(timestamp: Date(timeIntervalSince1970: timestamp), level: level, message: message)
    }
    
    /// Parse ISO8601 directly to Unix timestamp - no DateFormatter, no Calendar
    @inline(__always)
    private static func parseTimestamp(_ ptr: inout UnsafePointer<CChar>) -> TimeInterval? {
        @inline(__always) func digit(_ p: inout UnsafePointer<CChar>) -> Int {
            let v = Int(p.pointee) - 0x30
            p = p.advanced(by: 1)
            return v
        }
        
        let year = digit(&ptr) * 1000 + digit(&ptr) * 100 + digit(&ptr) * 10 + digit(&ptr)
        ptr = ptr.advanced(by: 1) // skip '-'
        let month = digit(&ptr) * 10 + digit(&ptr)
        ptr = ptr.advanced(by: 1) // skip '-'
        let day = digit(&ptr) * 10 + digit(&ptr)
        ptr = ptr.advanced(by: 1) // skip 'T'
        let hour = digit(&ptr) * 10 + digit(&ptr)
        ptr = ptr.advanced(by: 1) // skip ':'
        let minute = digit(&ptr) * 10 + digit(&ptr)
        ptr = ptr.advanced(by: 1) // skip ':'
        let second = digit(&ptr) * 10 + digit(&ptr)
        
        // Optional fractional seconds
        var fraction: Double = 0
        if ptr.pointee == 0x2E { // '.'
            ptr = ptr.advanced(by: 1)
            var divisor: Double = 10
            while ptr.pointee >= 0x30 && ptr.pointee <= 0x39 {
                fraction += Double(Int(ptr.pointee) - 0x30) / divisor
                divisor *= 10
                ptr = ptr.advanced(by: 1)
            }
        }
        
        // Convert to Unix timestamp directly (assumes UTC)
        var y = year
        var m = month
        if m <= 2 { y -= 1; m += 12 }
        
        let era = (y >= 0 ? y : y - 399) / 400
        let yoe = y - era * 400
        let doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) / 5 + day - 1
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
        let daysSinceEpoch = era * 146097 + doe - 719468
        
        return TimeInterval(daysSinceEpoch) * 86400 +
               TimeInterval(hour) * 3600 +
               TimeInterval(minute) * 60 +
               TimeInterval(second) +
               fraction
    }
    
    private static func extractMessage(from start: UnsafePointer<CChar>, to end: UnsafePointer<CChar>) -> String {
        // Trim trailing whitespace
        var actualEnd = end
        while actualEnd > start {
            let prev = actualEnd.advanced(by: -1)
            let c = prev.pointee
            if c == 0 || c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
                actualEnd = prev
            } else {
                break
            }
        }
        
        guard actualEnd > start else { return "" }
        
        // Build message, collapsing whitespace
        let length = start.distance(to: actualEnd)
        var result = ""
        result.reserveCapacity(length)
        
        var ptr = start
        var lastWasSpace = true
        while ptr < actualEnd {
            let c = ptr.pointee
            if c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
                if !lastWasSpace {
                    result.append(" ")
                    lastWasSpace = true
                }
            } else if c != 0 {
                result.append(Character(UnicodeScalar(UInt8(bitPattern: c))))
                lastWasSpace = false
            }
            ptr = ptr.advanced(by: 1)
        }
        
        if result.last == " " { result.removeLast() }
        return result
    }
    
    private static func stringFromCString(_ ptr: UnsafePointer<CChar>, length: Int) -> String {
        ptr.withMemoryRebound(to: UInt8.self, capacity: length) { bytes in
            String(decoding: UnsafeBufferPointer(start: bytes, count: length), as: UTF8.self)
        }
    }
}
