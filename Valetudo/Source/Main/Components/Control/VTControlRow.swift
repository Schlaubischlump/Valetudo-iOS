//
//  VTTitleControlView.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import UIKit

class VTControlRow<T: UIView>: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var title: String {
        didSet { refreshTitle() }
    }
    
    var subtitle: String? {
        didSet { refreshTitle() }
    }
    
    var attributedTitle: NSAttributedString? {
        get { titleLabel.attributedText }
        set { titleLabel.attributedText = newValue }
    }
    
    var titleIcon: UIImage? {
        get { titleIconView.image }
        set { titleIconView.image = newValue }
    }
    
    private var mainStack: UIStackView!
    
    let content: T
    
    init(title: String, titleIcon: UIImage?, content: T) {
        self.content = content
        self.title = title
        super.init(frame: .zero)
        setup()
        self.titleIcon = titleIcon
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func refreshTitle() {
        let fullString =
            if let subtitle {
                "\(title):   \(subtitle)"
            } else {
                "\(title)"
            }
        
        let attributed = NSMutableAttributedString(string: fullString)
        let titleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.label
        ]
        let subTitleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.tintColor
        ]
        
        let titleLength = title.count + (subtitle != nil ? 1 : 0)
        let titleRange = NSRange(location: 0, length: titleLength)
        attributed.addAttributes(titleAttributes, range: titleRange)

        if subtitle != nil {
            let subtitleStart = titleRange.location + titleRange.length
            let subtitleLength = fullString.count - subtitleStart
            let subtitleRange = NSRange(location: subtitleStart, length: subtitleLength)
            attributed.addAttributes(subTitleAttributes, range: subtitleRange)
        }
            
        UIView.transition(
            with: self.titleLabel,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.titleLabel.attributedText = attributed
            },
            completion: nil
        )
    }
    
    func setup() {
        // Container for label and icon, horizontally aligned
        let titleStack = UIStackView(arrangedSubviews: [titleIconView, titleLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 6
        titleStack.alignment = .center
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        refreshTitle()
        
        // Vertical container for title and buttons
        mainStack = UIStackView(arrangedSubviews: [titleStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.addArrangedSubview(content)
    
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleStack.heightAnchor.constraint(equalToConstant: 20),
            titleIconView.widthAnchor.constraint(equalToConstant: 20),
            titleIconView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
