//
//  VTStackedProgressBarSegment.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

struct VTStackedProgressBarSegment: Hashable {
    let value: CGFloat // 0...1 relative size inside its bar
    let color: UIColor
}
