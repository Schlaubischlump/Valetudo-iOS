//
//  VTItem.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation

/// We use a protocol instead of an enum, because separate cases of an enum can not be polymorphic over a dataype.
/// That is, the whole enum would be polymorphic, but that would constraint e.g. drop down menus or selection to a single type.
protocol VTItem: Sendable, Hashable {
    var id: String { get }
}
