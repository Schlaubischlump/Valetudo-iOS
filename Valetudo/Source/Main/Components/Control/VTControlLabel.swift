//
//  VTControlLabel.swift
//  Valetudo
//
//  Created by David Klopp on 05.09.25.
//
import UIKit

final class VTControlLabel: UIView, VTControlItem {
    var title: String = ""
    var subtitle: String = ""
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        self.title = title
        self.subtitle = subtitle
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
