//
//  VTItem.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation
import UIKit

/// We use a protocol instead of an enum, because separate cases of an enum can not be polymorphic over a dataype.
/// That is, the whole enum would be polymorphic, but that would constraint e.g. drop down menus or selection to a single type.
protocol VTItem: Sendable, Hashable {
    var id: String { get }
}

struct VTCheckboxItem: VTItem {
    let id: String
    let title: String
    let enabled: Bool
}

struct VTTextFieldItem: VTItem {
    let id: String
    let text: String
}

struct VTDropDownItem<T: Hashable & Sendable>: VTItem {
    let id: String
    let active: T
    let options: [T]
}

struct VTSegmentItem<T: Hashable & Sendable>: VTItem {
    let id: String
    let active: Set<T>
    let options: [T]
}

struct VTTimePickerItem: VTItem {
    let id: String
    let hours: Int
    let minutes: Int
}

struct VTListSelectionItem<T: Hashable & Sendable>: VTItem {
    let id: String
    let active: [T]
    let options: [T]
}

struct VTLoadingItem: VTItem {
    let id: String
    let message: String
}

struct VTProgressItem: VTItem {
    let id: String
    let message: String
    let progress: CGFloat
}

struct VTActionItem: VTItem {
    let id: String
    let title: String
    let subtitle: String
    let image: UIImage?
    let buttonTitle: String
    let buttonStyle: VTButtonStyle?
}

/// Protocol conformance to Hashable is not enough for the typechecker to understand that this type is indeed Hashable.
/// That means, UICollectionView diffable datasource can not be polymorphic over `any Hashable`.
/// That is why we use a type erasure instead that wraps our items and is indeed Hashable.
struct VTAnyItem: Hashable {
    private let _hash: @Sendable (inout Hasher) -> Void
    private let _isEqual: @Sendable (Any) -> Bool

    let base: any Sendable
    let id: String

    init<T: VTItem>(_ item: T) {
        base = item
        id = item.id

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

    static func checkbox(_ id: String, title: String, enabled: Bool) -> VTAnyItem {
        VTAnyItem(VTCheckboxItem(id: id, title: title, enabled: enabled))
    }

    static func textField(_ id: String, text: String) -> VTAnyItem {
        VTAnyItem(VTTextFieldItem(id: id, text: text))
    }

    static func dropDown<T: Hashable & Sendable>(_ id: String, active: T, options: [T]) -> VTAnyItem {
        VTAnyItem(VTDropDownItem(id: id, active: active, options: options))
    }

    static func segment<T: Hashable & Sendable>(_ id: String, active: Set<T>, options: [T]) -> VTAnyItem {
        VTAnyItem(VTSegmentItem(id: id, active: active, options: options))
    }

    static func timePicker(_ id: String, hours: Int, minutes: Int) -> VTAnyItem {
        VTAnyItem(VTTimePickerItem(id: id, hours: hours, minutes: minutes))
    }

    static func listSelection<T: Hashable & Sendable>(_ id: String, active: [T], options: [T]) -> VTAnyItem {
        VTAnyItem(VTListSelectionItem(id: id, active: active, options: options))
    }

    static func loading(_ id: String, message: String) -> VTAnyItem {
        VTAnyItem(VTLoadingItem(id: id, message: message))
    }

    static func progress(_ id: String, message: String, progress: CGFloat) -> VTAnyItem {
        VTAnyItem(VTProgressItem(id: id, message: message, progress: progress))
    }

    static func action(
        _ id: String,
        title: String,
        subtitle: String,
        image: UIImage?,
        buttonTitle: String,
        buttonStyle: VTButtonStyle? = nil
    ) -> VTAnyItem {
        VTAnyItem(
            VTActionItem(
                id: id,
                title: title,
                subtitle: subtitle,
                image: image,
                buttonTitle: buttonTitle,
                buttonStyle: buttonStyle
            )
        )
    }
}

typealias VTCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTAnyItem>
