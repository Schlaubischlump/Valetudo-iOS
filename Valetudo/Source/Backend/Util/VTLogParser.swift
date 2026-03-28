//
//  VTLogParser.swift
//  Valetudo
//

import Foundation
import os.log

/// High-performance log parser with SIMD-accelerated scanning and caching.
struct VTLogParser {
    
    private static let logger = Logger(subsystem: "Valetudo", category: "LogParser")
    
    /// Parses log data directly from bytes
    static func parse(data: Data) -> [VTLogLine] {
        guard !data.isEmpty else { return [] }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let result = data.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return [VTLogLine]()
            }
            return parseBytes(baseAddress, count: buffer.count)
        }
        
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        logger.debug("Parsed \(result.count) log entries from \(data.count) bytes in \(String(format: "%.4f", elapsed))s")
        
        return result
    }
    
    // MARK: - Timestamp Cache
    
    /// Cached day calculation to avoid repeated calendar math
    private struct TimestampCache {
        var year: Int = 0
        var month: Int = 0
        var day: Int = 0
        var daySeconds: Int = 0
        
        @inline(__always)
        mutating func getTimestamp(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, fraction: Double) -> TimeInterval {
            if year == self.year && month == self.month && day == self.day {
                return TimeInterval(daySeconds + hour * 3600 + minute * 60 + second) + fraction
            }
            
            var y = year, m = month
            if m <= 2 { y -= 1; m += 12 }
            let era = (y >= 0 ? y : y - 399) / 400
            let yoe = y - era * 400
            let doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) / 5 + day - 1
            let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
            let days = era * 146097 + doe - 719468
            
            self.year = year
            self.month = month
            self.day = day
            self.daySeconds = days * 86400
            
            return TimeInterval(daySeconds + hour * 3600 + minute * 60 + second) + fraction
        }
    }
    
    // MARK: - String Interning Cache
    
    /// Caches repeated strings (messages/levels) to avoid duplicate allocations
    private struct StringCache {
        private var cache: [Int: String] = [:]
        private var recentHashes: [Int] = []
        private let maxSize = 128
        
        @inline(__always)
        mutating func intern(from start: UnsafePointer<UInt8>, to end: UnsafePointer<UInt8>) -> String {
            let length = start.distance(to: end)
            guard length > 0 else { return "" }
            
            let hash = computeHash(start, length: length)
            
            if let cached = cache[hash] {
                if verifyCacheHit(cached, start: start, length: length) {
                    return cached
                }
            }
            
            let newString = String(decoding: UnsafeBufferPointer(start: start, count: length), as: UTF8.self)
            
            if recentHashes.count >= maxSize {
                let oldHash = recentHashes.removeFirst()
                cache.removeValue(forKey: oldHash)
            }
            cache[hash] = newString
            recentHashes.append(hash)
            
            return newString
        }
        
        @inline(__always)
        private func computeHash(_ ptr: UnsafePointer<UInt8>, length: Int) -> Int {
            // DJB2 hash - simple, fast, works on all platforms
            var hash: Int = 5381
            for i in 0..<min(length, 64) {
                hash = ((hash << 5) &+ hash) &+ Int(ptr[i])
            }
            return hash ^ length
        }
        
        @inline(__always)
        private func verifyCacheHit(_ cached: String, start: UnsafePointer<UInt8>, length: Int) -> Bool {
            guard cached.utf8.count == length else { return false }
            var i = 0
            for byte in cached.utf8 {
                if byte != start[i] { return false }
                i += 1
            }
            return true
        }
    }
    
    // MARK: - Core Parser
    
    private static func parseBytes(_ bytes: UnsafePointer<UInt8>, count: Int) -> [VTLogLine] {
        let boundaries = findEntryBoundariesSIMD(bytes, count: count)
        
        guard !boundaries.isEmpty else { return [] }
        
        var results = [VTLogLine]()
        results.reserveCapacity(boundaries.count)
        
        var timestampCache = TimestampCache()
        var stringCache = StringCache()
        
        for i in 0..<boundaries.count {
            let entryStart = boundaries[i]
            let entryEnd = (i + 1 < boundaries.count) ? boundaries[i + 1] : count
            
            if let entry = parseEntryAt(bytes: bytes, start: entryStart, end: entryEnd,
                                         timestampCache: &timestampCache, stringCache: &stringCache) {
                results.append(entry)
            }
        }
        
        results.reverse()
        return results
    }
    
    // MARK: - SIMD Boundary Detection
    
    private static func findEntryBoundariesSIMD(_ bytes: UnsafePointer<UInt8>, count: Int) -> [Int] {
        var boundaries: [Int] = []
        boundaries.reserveCapacity(1000)
        
        var i = 0
        let bracket = SIMD32<UInt8>(repeating: 0x5B)
        
        while i + 32 <= count {
            let chunk = UnsafeRawPointer(bytes.advanced(by: i)).load(as: SIMD32<UInt8>.self)
            let matches = chunk .== bracket
            
            if matches != SIMDMask(repeating: false) {
                for j in 0..<32 where matches[j] {
                    if looksLikeTimestamp(bytes, at: i + j, end: count) {
                        boundaries.append(i + j)
                    }
                }
            }
            i += 32
        }
        
        while i < count {
            if bytes[i] == 0x5B && looksLikeTimestamp(bytes, at: i, end: count) {
                boundaries.append(i)
            }
            i += 1
        }
        
        return boundaries
    }
    
    @inline(__always)
    private static func looksLikeTimestamp(_ bytes: UnsafePointer<UInt8>, at offset: Int, end: Int) -> Bool {
        guard offset + 11 < end else { return false }
        let p = bytes.advanced(by: offset + 1)
        return isDigit(p[0]) && isDigit(p[1]) && isDigit(p[2]) && isDigit(p[3]) &&
               p[4] == 0x2D &&
               isDigit(p[5]) && isDigit(p[6]) &&
               p[7] == 0x2D &&
               isDigit(p[8]) && isDigit(p[9]) &&
               p[10] == 0x54
    }
    
    @inline(__always)
    private static func isDigit(_ c: UInt8) -> Bool {
        (c &- 0x30) < 10
    }
    
    // MARK: - Entry Parsing
    
    private static func parseEntryAt(bytes: UnsafePointer<UInt8>, start: Int, end: Int,
                                      timestampCache: inout TimestampCache,
                                      stringCache: inout StringCache) -> VTLogLine? {
        var ptr = bytes.advanced(by: start + 1)
        let entryEnd = bytes.advanced(by: end)
        
        guard let timestamp = parseTimestamp(&ptr, cache: &timestampCache) else { return nil }
        
        while ptr < entryEnd && ptr.pointee != 0x5D { ptr = ptr.successor() }
        if ptr < entryEnd { ptr = ptr.successor() }
        
        while ptr < entryEnd && isWhitespace(ptr.pointee) {
            ptr = ptr.successor()
        }
        
        var level = ""
        if ptr < entryEnd && ptr.pointee == 0x5B {
            let levelStart = ptr.advanced(by: 1)
            var levelEnd = levelStart
            while levelEnd < entryEnd && levelEnd.pointee != 0x5D {
                levelEnd = levelEnd.successor()
            }
            if levelEnd < entryEnd {
                level = stringCache.intern(from: levelStart, to: levelEnd)
                ptr = levelEnd.advanced(by: 1)
                while ptr < entryEnd && (ptr.pointee == 0x20 || ptr.pointee == 0x09) {
                    ptr = ptr.successor()
                }
            }
        }
        
        let message = extractMessage(from: ptr, to: entryEnd, cache: &stringCache)
        
        return VTLogLine(timestamp: Date(timeIntervalSince1970: timestamp), level: level, message: message)
    }
    
    @inline(__always)
    private static func isWhitespace(_ c: UInt8) -> Bool {
        c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D
    }
    
    @inline(__always)
    private static func parseTimestamp(_ ptr: inout UnsafePointer<UInt8>, cache: inout TimestampCache) -> TimeInterval? {
        @inline(__always) func d(_ p: inout UnsafePointer<UInt8>) -> Int {
            let v = Int(p.pointee) &- 0x30
            p = p.successor()
            return v
        }
        
        let year = d(&ptr) * 1000 + d(&ptr) * 100 + d(&ptr) * 10 + d(&ptr)
        ptr = ptr.successor()
        let month = d(&ptr) * 10 + d(&ptr)
        ptr = ptr.successor()
        let day = d(&ptr) * 10 + d(&ptr)
        ptr = ptr.successor()
        let hour = d(&ptr) * 10 + d(&ptr)
        ptr = ptr.successor()
        let minute = d(&ptr) * 10 + d(&ptr)
        ptr = ptr.successor()
        let second = d(&ptr) * 10 + d(&ptr)
        
        var fraction: Double = 0
        if ptr.pointee == 0x2E {
            ptr = ptr.successor()
            var div: Double = 10
            while isDigit(ptr.pointee) {
                fraction += Double(Int(ptr.pointee) &- 0x30) / div
                div *= 10
                ptr = ptr.successor()
            }
        }
        
        return cache.getTimestamp(year: year, month: month, day: day,
                                   hour: hour, minute: minute, second: second,
                                   fraction: fraction)
    }
    
    private static func extractMessage(from start: UnsafePointer<UInt8>, to end: UnsafePointer<UInt8>, cache: inout StringCache) -> String {
        var actualEnd = end
        while actualEnd > start {
            let c = actualEnd.advanced(by: -1).pointee
            if c != 0x20 && c != 0x09 && c != 0x0A && c != 0x0D && c != 0 {
                break
            }
            actualEnd = actualEnd.advanced(by: -1)
        }
        
        guard actualEnd > start else { return "" }
        
        var needsNormalization = false
        var scanPtr = start
        while scanPtr < actualEnd {
            let c = scanPtr.pointee
            if c == 0x0A || c == 0x0D || c == 0x09 {
                needsNormalization = true
                break
            }
            if c == 0x20 && scanPtr.successor() < actualEnd && scanPtr.successor().pointee == 0x20 {
                needsNormalization = true
                break
            }
            scanPtr = scanPtr.successor()
        }
        
        if needsNormalization {
            return normalizeMessage(from: start, to: actualEnd)
        }
        
        return cache.intern(from: start, to: actualEnd)
    }
    
    private static func normalizeMessage(from start: UnsafePointer<UInt8>, to end: UnsafePointer<UInt8>) -> String {
        var result = ContiguousArray<UInt8>()
        result.reserveCapacity(start.distance(to: end))
        
        var ptr = start
        var lastWasSpace = true
        while ptr < end {
            let c = ptr.pointee
            if isWhitespace(c) {
                if !lastWasSpace {
                    result.append(0x20)
                    lastWasSpace = true
                }
            } else {
                result.append(c)
                lastWasSpace = false
            }
            ptr = ptr.successor()
        }
        
        if result.last == 0x20 { result.removeLast() }
        
        return result.withUnsafeBufferPointer { String(decoding: $0, as: UTF8.self) }
    }
}
