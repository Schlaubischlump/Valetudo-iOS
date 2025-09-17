//
//  VTHeaderView.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import UIKit

class VTHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "VTHeaderView"

    private let label: UILabel = {
        let label = UILabel()
        label.text = nil
        label.textAlignment = .left
        label.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
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
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        label.text = text
    }
}
