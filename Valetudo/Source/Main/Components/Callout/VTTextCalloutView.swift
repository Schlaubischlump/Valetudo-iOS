//
//  VTTextCalloutView.swift
//  Valetudo
//
//  Created by David Klopp on 27.04.26.
//
import UIKit

fileprivate let textCalloutPadX = 12.0
fileprivate let textCalloutPadY = 8.0
fileprivate let textCalloutSpacing = 4.0

final class VTTextCalloutView: VTCalloutView {
    private let contentStack = UIStackView()
    
    override init(title: String, subtitle: String) {
        super.init(title: title, subtitle: subtitle)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentStack.axis = .vertical
        contentStack.spacing = textCalloutSpacing
        contentStack.alignment = .leading
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: textCalloutPadY),
            contentStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -textCalloutPadY),
            contentStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: textCalloutPadX),
            contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -textCalloutPadX)
        ])
    }
}
