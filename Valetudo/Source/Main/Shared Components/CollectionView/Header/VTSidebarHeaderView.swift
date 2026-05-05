//
//  VTHeaderView.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import UIKit

class VTSidebarHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "VTSidebarHeaderView"

    private let label: UILabel = {
        let label = UILabel()
        label.text = nil
        label.textAlignment = .left
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize, weight: .medium)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        label.text = text
    }
}
