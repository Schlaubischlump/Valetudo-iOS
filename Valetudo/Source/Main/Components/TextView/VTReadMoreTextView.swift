//
//  VTReadMoreTextView.swift
//  Valetudo
//
//  Created by David Klopp on 21.09.25.
//
import UIKit

final class VTReadMoreTextView: UITextView, UITextViewDelegate {
    static let readMoreAction = "action://readmore"
    static let readLessAction = "action://readless"

    private var fullAttributedText: NSAttributedString?
    private var isExpanded = false
    private let maxLength: Int

    /// Optional reload handler, e.g. to trigger collectionView reload
    var reloadHandler: (() -> Void)?

    /// Appearance
    var baseFont: UIFont = .systemFont(ofSize: 14) {
        didSet { updateText() }
    }
    var baseTextColor: UIColor = .secondaryLabel {
        didSet { updateText() }
    }

    init(maxLength: Int = 150) {
        self.maxLength = maxLength
        super.init(frame: .zero, textContainer: nil)
        setup()
    }

    required init?(coder: NSCoder) {
        self.maxLength = 150
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        delegate = self
        isEditable = false
        isSelectable = true
        isScrollEnabled = false
        dataDetectorTypes = []
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        backgroundColor = .clear
    }

    func configure(with attributedText: NSAttributedString) {
        fullAttributedText = attributedText
        updateText()
    }

    private func updateText() {
        guard let fullText = fullAttributedText else { return }

        let needsTruncating = fullText.length > maxLength
        let range = NSRange(location: 0, length: isExpanded ? fullText.length : min(maxLength, fullText.length))
        let mutable = NSMutableAttributedString(attributedString: fullText.attributedSubstring(from: range))

        if needsTruncating {
            mutable.append(NSAttributedString(string: isExpanded ? "  " : "… "))
        }

        // Apply base font + color to all text
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: baseTextColor
        ]
        mutable.addAttributes(baseAttributes, range: NSRange(location: 0, length: mutable.length))

        if needsTruncating {
            let label = isExpanded ? "READ_LESS" : "READ_MORE"
            let actionURL = URL(string: isExpanded ? Self.readLessAction : Self.readMoreAction)!
            let readActionLink = NSAttributedString(
                string: label.localized(),
                attributes: [
                    .link: actionURL,
                    .font: baseFont,
                    .foregroundColor: tintColor ?? .systemBlue
                ]
            )
            mutable.append(readActionLink)
        }

        attributedText = mutable

        // Notify owner to refresh layout
        reloadHandler?()
    }

    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        guard case .link(let url) = textItem.content else { return nil }

        switch url.absoluteString {
        case Self.readMoreAction:
            return UIAction { [weak self] _ in
                self?.isExpanded = true
                self?.updateText()
            }
        case Self.readLessAction:
            return UIAction { [weak self] _ in
                self?.isExpanded = false
                self?.updateText()
            }
        default:
            return defaultAction
        }
    }
}

