//
//  Array + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 18.09.25.
//
extension Array {
    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
