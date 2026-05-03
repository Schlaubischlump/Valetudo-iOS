//
//  VTAnyItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation

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
}
