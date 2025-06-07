//
//  VTLegendItem.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

struct VTLegendItem {
    let color: UIColor
    let text: String

    init(color: UIColor, text: String) {
        self.color = color
        self.text = text
    }

    init(color: CGColor, text: String) {
        self.color = UIColor(cgColor: color)
        self.text = text
    }
}
