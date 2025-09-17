//
//  VTFooterView.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import UIKit

final class VTFooterView: UICollectionReusableView, UITextViewDelegate {
    static let reuseIdentifier = "VTFooterView"
    static let readMoreAction = "action://readmore"
    static let readLessAction = "action://readless"

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.isScrollEnabled = false
        tv.dataDetectorTypes = []
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        return tv
    }()

    private var fullAttributedText: NSAttributedString?
    private var isExpanded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        textView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(attributedText: NSAttributedString) {
        fullAttributedText = attributedText
        updateText()
    }

    private func updateText() {
        guard let fullText = fullAttributedText else { return }

        // Configure the text
        let maxLength =  150
        let needsTruncating = fullText.length > maxLength
        
        let range = NSRange(location: 0, length: isExpanded ? fullText.length : min(maxLength, fullText.length))
        let mutable = NSMutableAttributedString(attributedString: fullText.attributedSubstring(from: range))
        
        if (needsTruncating) {
            mutable.append(NSAttributedString(string: isExpanded ? "  " : "… "))
        }
        
        let truncatedRange = NSRange(location: 0, length: mutable.length)
        mutable.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: truncatedRange)
        
        if (needsTruncating) {
            let label = isExpanded ? "READ_LESS" : "READ_MORE"
            let actionURL = URL(string: isExpanded ? Self.readLessAction : Self.readMoreAction)!
            let readActionLink = NSAttributedString(
                string: label.localizedCapitalized(),
                attributes: [.link: actionURL, .foregroundColor: tintColor ?? .systemBlue]
            )
            mutable.append(readActionLink)
        }
        
        textView.attributedText = mutable
        
        guard let collectionView = self.superview as? UICollectionView else { return }
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        guard case .link(let url) = textItem.content else { return nil }
        
        return switch (url.absoluteString) {
        case Self.readMoreAction:
            UIAction { [weak self] _ in
                self?.isExpanded = true
                self?.updateText()
            }
        case Self.readLessAction:
            UIAction { [weak self] _ in
                self?.isExpanded = false
                self?.updateText()
            }
        default:
            defaultAction
        }
    }
}

