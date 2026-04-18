//
//  VTSelectionItem.swift
//  Valetudo
//
//  Created by David Klopp on 05.10.25.
//

// This is effectively a CustomStringConvertible. However, we return localized strings here.
// I think its cleaner to have a separate protocol for it.

public protocol Describable {
    var description: String { get }
}

extension String: Describable {
    public var description: String { self }
}

extension Int: Describable {
    public var description: String { "\(self)" }
}
