//
//  VTVirtualWallMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 09.10.25.
//

import CoreGraphics
import Foundation
import UIKit

/// Transient line overlay used for virtual walls.
@MainActor
final class VTVirtualWallMapOverlay: VTLineMapOverlay {
    init(startPoint: CGPoint, endPoint: CGPoint) {
        super.init(
            startPoint: startPoint,
            endPoint: endPoint,
            minimumLength: 28.0,
            style: .init(
                bodyColor: UIColor.systemPurple.cgColor,
                strokeColor: UIColor.black.cgColor,
                thickness: 3.0,
                strokeWidth: 1.5,
                insertionBehavior: .horizontal(length: 40.0)
            )
        )
    }
}
