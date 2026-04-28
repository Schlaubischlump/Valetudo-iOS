//
//  VTControlButton.swift
//  Valetudo
//
//  Created by David Klopp on 05.09.25.
//
import UIKit

class VTControlButton: UIButton, VTControlItem {
    var onTap: (() -> Void)?

    static let baseBackgroundColor: UIColor = .systemGray5 /* UIColor { traitCollection in
         traitCollection.userInterfaceStyle == .dark
         ? UIColor(red: 49.0/255.0, green: 49.0/255.0, blue: 52.0/255.0, alpha: 1.0)
         : UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1.0)
     } */ // .quaternarySystemFill //.systemFill //.secondarySystemFill
    static let baseForegroundColor: UIColor = .label
    static let highlightedBackgroundColor: UIColor = .tintColor

    fileprivate var isActive: Bool {
        isHighlighted
    }

    private var _title: String?

    static func defaultConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 4
        config.baseForegroundColor = .label
        // let glassEffect = UIGlassEffect(style: .regular)
        // glassEffect.tintColor = VTControlButton.baseBackgroundColor
        // config.background.visualEffect = glassEffect//UIBlurEffect(style: .systemChromeMaterialDark)
        // UIBlurEffect(style: .systemThickMaterial)
        config.background.backgroundColor = VTControlButton.baseBackgroundColor
        config.baseBackgroundColor = VTControlButton.baseBackgroundColor
        config.cornerStyle = .medium
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            return outgoing
        }
        return config
    }

    init(title: String?, icon: UIImage?, config _: UIButton.Configuration = VTControlButton.defaultConfiguration()) {
        _title = title
        super.init(frame: .zero)

        preferredBehavioralStyle = .pad
        var config = VTControlButton.defaultConfiguration()
        config.title = title
        config.image = icon
        configurationUpdateHandler = updateButton
        configuration = config
        addTarget(self, action: #selector(buttonPushed(_:)), for: .touchUpInside)
    }

    func updateButton(_ button: UIButton) {
        guard let controlButton = button as? VTControlButton else { return }
        let isDark = controlButton.traitCollection.userInterfaceStyle == .dark
        let isActive = controlButton.isActive

        if isDark {
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

    @objc fileprivate func buttonPushed(_: UIButton) {
        onTap?()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

final class VTToggleControlButton: VTControlButton {
    override fileprivate var isActive: Bool {
        isHighlighted || isToggled
    }

    private var _isToggled: Bool = false

    var isToggled: Bool {
        get { _isToggled }
        set {
            guard isEnabled else { return }
            _isToggled = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override fileprivate func buttonPushed(_ sender: UIButton) {
        isToggled.toggle()
        super.buttonPushed(sender)
    }
}
