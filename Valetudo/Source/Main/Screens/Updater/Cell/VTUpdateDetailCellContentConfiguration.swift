//
//  VTUpdateAvailableCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

struct VTUpdateDetailCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    var title: String
    var subtitle: String
    var image: UIImage?
    var attributedMessage: NSAttributedString
    var baseFont: UIFont = .systemFont(ofSize: UIFont.labelFontSize)
    var baseTextColor: UIColor = .label
    var buttonTitle: String
    var buttonAction: (UIButton) -> Void
    
    func makeContentView() -> UIView & UIContentView {
        VTUpdateDetailCellView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTUpdateDetailCellContentConfiguration {
        self
    }
    
    static func == (lhs: VTUpdateDetailCellContentConfiguration, rhs: VTUpdateDetailCellContentConfiguration) -> Bool {
        lhs.attributedMessage == rhs.attributedMessage &&
        lhs.buttonTitle == rhs.buttonTitle &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.image == rhs.image
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(image)
        hasher.combine(attributedMessage)
        hasher.combine(buttonTitle)
    }
}
