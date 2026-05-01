//
//  VTKeyboardEvent.swift
//  Valetudo
//
//  Created by David Klopp on 12.10.25.
//

import UIKit

enum VTKeyboardEvent: Hashable {
    case upArrow
    case downArrow
    case leftArrow
    case rightArrow

    @MainActor
    init?(key: UIKey) {
        switch key.keyCode {
        case .keyboardUpArrow:
            self = .upArrow
        case .keyboardDownArrow:
            self = .downArrow
        case .keyboardLeftArrow:
            self = .leftArrow
        case .keyboardRightArrow:
            self = .rightArrow
        default:
            return nil
        }
    }
}
