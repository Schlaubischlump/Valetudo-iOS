//
//  VTEventItem.swift
//  Valetudo
//
//  Created by David Klopp on 19.04.26.
//
import Foundation
import UIKit

struct VTEventItem: Hashable, Sendable {
    private let _hash: @Sendable (inout Hasher) -> Void
    private let _isEqual: @Sendable (Any) -> Bool
    
    private let event: any VTEvent
    
    init<T: VTEvent>(event: T) {
        self.event = event
        
        _hash = { hasher in event.hash(into: &hasher) }
        _isEqual = { other in
            guard let other = other as? T else { return false }
            return other == event
        }
    }
    
    var id: String { event.id }
    var timestamp: Date { event.timestamp }
    var title: String { event.description }
    var processed: Bool { event.processed }
    
    @MainActor
    func createContextualAction(_ interact: @escaping ((VTEventInteraction) async -> Bool) ) -> [UIContextualAction] {
        switch (event) {
        case _ as VTConsumableDepletedEvent:
            return [
                UIContextualAction(style: .destructive, title: "RESET".localizedCapitalized()) { _,_,completion in
                    Task { completion(await interact(.reset)) }
                }
            ]
        case _ as VTMissingResourceEvent,
            _ as VTDustBinFullEvent,
            _ as VTErrorStateEvent,
            _ as VTMopAttachmentReminderEvent:
            return [
                UIContextualAction(style: .destructive, title: "DISMISS".localizedCapitalized()) { _,_,completion in
                    Task { completion(await interact(.ok)) }
                }
            ]
        case _ as VTPendingMapChangeEvent:
            return [
                UIContextualAction(style: .destructive, title: "NO".localizedCapitalized()) { _,_,completion in
                    Task { completion(await interact(.no)) }
                },
                UIContextualAction(style: .normal, title: "YES".localizedCapitalized(), color: .systemGreen) { _,_,completion in
                    Task { completion(await interact(.yes)) }
                }
            ]
        default:
            return []
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._isEqual(rhs.event)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // identity
        _hash(&hasher)
    }
}
