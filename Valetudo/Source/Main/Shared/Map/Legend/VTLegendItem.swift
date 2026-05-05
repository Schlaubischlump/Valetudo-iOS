//
//  VTLegendItem.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

/// Immutable presentation model for one entry in the map legend.
struct VTLegendItem {
    let color: UIColor
    let text: String

    /// Creates a legend item from a UIKit color and display text.
    init(color: UIColor, text: String) {
        self.color = color
        self.text = text
    }

    /// Creates a legend item from a Core Graphics color and display text.
    init(color: CGColor, text: String) {
        self.color = UIColor(cgColor: color)
        self.text = text
    }
}
