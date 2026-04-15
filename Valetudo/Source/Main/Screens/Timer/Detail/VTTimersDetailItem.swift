//
//  VTTimersItem.swift
//  Valetudo
//
//  Created by David Klopp on 12.04.26.
//
import Foundation

/// We use a protocol instead of an enum, because separate cases of an enum can not be polymorphic over a dataype.
/// That is, the whole enum would be polymorphic, but that would constraint e.g. drop down menus or selection to a single type.
protocol VTTimersDetailItem: Sendable, Hashable {
    var id: String { get }
}

struct VTCheckboxItem: VTTimersDetailItem {
    let id: String
    let title: String
    let enabled: Bool
}

struct VTTextFieldItem: VTTimersDetailItem {
    let id: String
    let text: String
}

struct VTDropDownItem<T: Hashable & Sendable>: VTTimersDetailItem {
    let id: String
    let active: T
    let options: [T]
}

struct VTSegmentItem<T: Hashable & Sendable>: VTTimersDetailItem {
    let id: String
    let active: Set<T>
    let options: [T]
}

struct VTTimePickerItem: VTTimersDetailItem {
    let id: String
    let hours: Int
    let minutes: Int
}

struct VTListSelectionItem<T: Hashable & Sendable>: VTTimersDetailItem {
    let id: String
    let active: [T]
    let options: [T]
}

/// Protocol conformance to Hashable is not enough for the typechecker to understand that this type is indeed Hashable.
/// That means, UICollectionView diffable datasource can not be polymorphic over `any Hashable`.
/// That is why we use a type erasure instead that wraps our items and is indeed Hashable.
struct VTAnyTimersDetailItem: Hashable, Sendable {
    private let _hash: @Sendable (inout Hasher) -> Void
    private let _isEqual: @Sendable (Any) -> Bool

    let base: any Sendable
    let id: String

    init<T: VTTimersDetailItem>(_ item: T) {
        self.base = item
        self.id = item.id

        _hash = { hasher in item.hash(into: &hasher) }
        _isEqual = { other in
            guard let other = other as? T else { return false }
            return other == item
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._isEqual(rhs.base)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // identity
        _hash(&hasher)
    }
    
    // MARK: - Factory
    
    static func checkbox(_ id: String, title: String, enabled: Bool) -> VTAnyTimersDetailItem {
        VTAnyTimersDetailItem(VTCheckboxItem(id: id, title: title, enabled: enabled))
    }

    static func textField(_ id: String, text: String) -> VTAnyTimersDetailItem {
        VTAnyTimersDetailItem(VTTextFieldItem(id: id, text: text))
    }

    static func dropDown<T: Hashable & Sendable>(_ id: String, active: T, options: [T]) -> VTAnyTimersDetailItem {
        VTAnyTimersDetailItem(VTDropDownItem(id: id, active: active, options: options))
    }

    static func segment<T: Hashable & Sendable>(_ id: String, active: Set<T>, options: [T]) -> VTAnyTimersDetailItem {
        VTAnyTimersDetailItem(VTSegmentItem(id: id, active: active, options: options))
    }

    static func timePicker(_ id: String, hours: Int, minutes: Int) -> VTAnyTimersDetailItem {
        VTAnyTimersDetailItem(VTTimePickerItem(id: id, hours: hours, minutes: minutes))
    }

    static func listSelection<T: Hashable & Sendable>(_ id: String, active: [T], options: [T]) -> VTAnyTimersDetailItem {
        VTAnyTimersDetailItem(VTListSelectionItem(id: id, active: active, options: options))
    }
}


