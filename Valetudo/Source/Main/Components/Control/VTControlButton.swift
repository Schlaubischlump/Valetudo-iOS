//
//  VTControlButton.swift
//  Valetudo
//
//  Created by David Klopp on 05.09.25.
//
import UIKit

class VTControlButton: UIButton, VTControlItem {
    var onTap: (() -> Void)?
    
    static let baseBackgroundColor: UIColor = .secondarySystemFill
    static let baseForegroundColor: UIColor = .label
    static let highlightedBackgroundColor: UIColor = .tintColor
    
    fileprivate var isActive: Bool { isHighlighted }
    
    private var _title: String?
    
    static func defaultConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 4
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        config.baseBackgroundColor = VTControlButton.baseBackgroundColor
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            return outgoing
        }
        return config
    }
    
    init(title: String?, icon: UIImage?, config: UIButton.Configuration = VTControlButton.defaultConfiguration()) {
        self._title = title
        super.init(frame: .zero)
        var config = VTControlButton.defaultConfiguration()
        config.title = title
        config.image = icon
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


final class VTToggleControlButton: VTControlButton {
    fileprivate override var isActive: Bool { isHighlighted || isToggled }
    
    private var _isToggled: Bool = false
    
    var isToggled: Bool {
        get { _isToggled }
        set {
            guard isEnabled else { return }
            _isToggled = newValue
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override fileprivate func buttonPushed(_ sender: UIButton) {
        isToggled.toggle()
        super.buttonPushed(sender)
    }
}
