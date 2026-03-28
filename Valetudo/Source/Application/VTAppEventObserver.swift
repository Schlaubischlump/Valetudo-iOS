//
//  VTAppEventObserver.swift
//  Valetudo
//
//  Created by David Klopp on 28.03.26.
//
import Foundation
import UIKit

@MainActor
protocol VTAppEventObserver {
    var observer: NSObjectProtocol? { get set }
    
    func subscribe(_ handler: @escaping @Sendable (Notification) -> Void)
    func unsubscribe()
}
