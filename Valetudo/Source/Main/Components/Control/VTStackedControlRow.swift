//
//  VTDockControlView.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

protocol VTControlItem: UIView {}

class VTControlLabel: UIView, VTControlItem {
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

class VTControlButton: UIButton, VTControlItem {
    var onTap: (() -> Void)?
    
    static let baseBackgroundColor: UIColor = .secondarySystemFill
    static let baseForegroundColor: UIColor = .label
    static let highlightedBackgroundColor: UIColor = .tintColor
    
    fileprivate var isActive: Bool { isHighlighted }
    
    init(title: String?, icon: UIImage?) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = icon
        config.imagePadding = 4
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        config.baseBackgroundColor = VTControlButton.baseBackgroundColor
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            return outgoing
        }
        self.configurationUpdateHandler = updateButton
        self.configuration = config
        self.addTarget(self, action: #selector(self.buttonPushed(_:)), for: .touchUpInside)
    }
    
    func updateButton(_ button: UIButton) {
        guard let controlButton = button as? VTControlButton else { return }
        let isDark = controlButton.traitCollection.userInterfaceStyle == .dark
        let isActive = controlButton.isActive
        
        if (isDark) {
            button.configuration?.background.backgroundColor = !isActive
                ? VTControlButton.baseBackgroundColor
                : VTControlButton.highlightedBackgroundColor
            button.configuration?.baseForegroundColor = !isActive
                ? VTControlButton.baseForegroundColor
                : VTControlButton.baseForegroundColor.inverted()
        } else {
            button.configuration?.background.backgroundColor = !isActive
                ? VTControlButton.baseBackgroundColor
                : VTControlButton.highlightedBackgroundColor
            button.configuration?.baseForegroundColor = !isActive
                ? VTControlButton.baseForegroundColor
                : VTControlButton.baseForegroundColor.inverted()
        }
    }
    
    @objc fileprivate func buttonPushed(_ sender: UIButton) {
        onTap?()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class VTToggleControlButton: VTControlButton {
    fileprivate override var isActive: Bool { isHighlighted || isToggled }
    
    private var _isToggled: Bool = false
    
    var isToggled: Bool {
        get { _isToggled }
        set {
            guard isEnabled else { return }
            _isToggled = newValue
            print("Is toggled: \(_isToggled)")
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override fileprivate func buttonPushed(_ sender: UIButton) {
        isToggled.toggle()
        super.buttonPushed(sender)
    }
}


class VTStackedControlRow<T: VTControlItem>: VTControlRow<UIStackView> {
    var items: [T] = [] {
        didSet {
            content.arrangedSubviews.forEach({$0.removeFromSuperview()})
            items.forEach({content.addArrangedSubview($0)})
        }
    }

    var axis: NSLayoutConstraint.Axis {
        get { content.axis }
        set { content.axis = newValue }
    }
    
    init(title: String, titleIcon: UIImage?) {
        super.init(title: title, titleIcon: titleIcon, content: UIStackView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        // Horizontal stack for buttons
        content.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .horizontal
        content.spacing = 8
        content.distribution = .fillEqually
    }
}

extension VTStackedControlRow where T == VTControlButton {
    var isEnabled: Bool {
        get { self.items.allSatisfy(\.isEnabled) }
        set { self.items.forEach({ $0.isEnabled = newValue }) }
    }
}
