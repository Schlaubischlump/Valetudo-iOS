//
//  VTFooterView.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import UIKit

final class VTFooterView: UICollectionReusableView {
    static let reuseIdentifier = "VTFooterView"

    private let textView = VTReadMoreTextView(maxLength: 150)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(attributedText: NSAttributedString) {
        textView.configure(with: attributedText)
        textView.baseTextColor = .secondaryLabel
        textView.baseFont = .systemFont(ofSize: UIFont.smallSystemFontSize)
        textView.reloadHandler = { [weak self] in
            let collectionView = self?.enclosingCollectionView as? UICollectionView
            let layout = collectionView?.collectionViewLayout
            layout?.invalidateLayout()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(attributedText: NSAttributedString(string: ""))
    }
}
