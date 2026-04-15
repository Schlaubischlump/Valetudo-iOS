//
//  Sequence + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 13.04.26.
//
import Foundation

extension Sequence {
    func unzip<A, B>() -> ([A], [B]) where Element == (A, B) {
        var a: [A] = []
        var b: [B] = []
        a.reserveCapacity(underestimatedCount)
        b.reserveCapacity(underestimatedCount)

        for (x, y) in self {
            a.append(x)
            b.append(y)
        }

        return (a, b)
    }
    
    func swapped<A, B>() -> [(B, A)] where Element == (A, B) {
        map { ($0.1, $0.0) }
    }
    
    func reverseEnumerated() -> [(Element, Int)] {
        enumerated().map { ($0.element, $0.offset) }
    }
}
