//
//  VTConsumablesContentView.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

class VTConsumablesContentView: UIView, UIContentView {
    private var currentConfiguration: VTConsumablesCellContentConfiguration!
    
    private lazy var titleLabel = {
        let label = UILabel()
        //label.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var progressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        //progressView.trackTintColor = .darkGray
        progressView.progressTintColor = tintColor
        return progressView
    }()
    
    private lazy var remainingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var resetButton = {
        let resetButton = VTOutlineButton(title: "RESET".localized(), tintColor: tintColor)
        return resetButton
    }()
    
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? VTConsumablesCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    
    init(configuration: VTConsumablesCellContentConfiguration) {
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, progressView, remainingLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
                        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIStackView(arrangedSubviews: [textStack, resetButton])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 40
        container.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        remainingLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        resetButton.setContentHuggingPriority(.required, for: .horizontal)
        resetButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
    }
    
    private func apply(configuration: VTConsumablesCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        titleLabel.text = configuration.title
        remainingLabel.text = "Remaining: ".localized() + "\(configuration.remaining)"
        progressView.progress = configuration.progress
        resetButton.isHidden = !configuration.showsReset
    }
    
    @objc private func didTapReset() {
        currentConfiguration.onReset?()
    }
}
