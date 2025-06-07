//
//  VTCalloutview.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//

import UIKit

fileprivate let padX = 12.0
fileprivate let padY = 8.0
fileprivate let itemSpacing = 4.0

class VTCalloutView: UIView {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setupViews()
        configure(title: title, subtitle: subtitle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Title label styling
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        // Subtitle label styling
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        // Stack View
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = itemSpacing
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)

        // Constraints
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padY),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padY),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padX),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padX)
        ])
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    override var intrinsicContentSize: CGSize {
        let width = max(titleLabel.intrinsicContentSize.width, subtitleLabel.intrinsicContentSize.width)
        let height = titleLabel.intrinsicContentSize.height + subtitleLabel.intrinsicContentSize.height
        return CGSize(width: width + padX * 2, height: height + padY * 2 + itemSpacing)
    }
}
