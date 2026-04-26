//
//  VTCalloutview.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//

import UIKit

class VTCalloutView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    var onClose: (() -> Void)?
    var preferredContentWidth: CGFloat? { nil }
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setupLabels()
        configure(title: title, subtitle: subtitle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
    }
    
    private func setupLabels() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}




