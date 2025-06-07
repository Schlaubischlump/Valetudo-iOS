//
//  VTStartPauseStopControl.swift
//  Valetudo
//
//  Created by David Klopp on 23.05.25.
//
import UIKit

class VTStartPauseStopControlRow: UIStackView {
    
    var onStartPauseCliked: ((_ isStarted: Bool) -> Void)?
    var onStopClicked: (() -> Void)?
    var onHomeClicked: (() -> Void)?
    
    var isStartPauseEnabled: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self else { return }
                startPauseButton.isEnabled = isStartPauseEnabled
            }
        }
    }
    
    var isStopEnabled: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self else { return }
                stopButton.isEnabled = isStopEnabled
            }
        }
    }
    
    var isHomeEnabled: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self else { return }
                homeButton.isEnabled = isHomeEnabled
            }
        }
    }
    
    var isStarted: Bool = false {
        didSet {
            let imageName = isStarted ? "pause.fill" : "play.fill"
            startPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
        
    private let startPauseButton = VTControlButton(title: nil, icon: UIImage(systemName: "play.fill"))
    private let stopButton = VTControlButton(title: nil, icon: UIImage(systemName: "stop.fill"))
    private let homeButton = VTControlButton(title: nil, icon: UIImage(systemName: "house.fill"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = -1
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        setupButton(startPauseButton)
        setupButton(stopButton)
        setupButton(homeButton)

        applySegmentedStyle(to: startPauseButton, position: .left)
        applySegmentedStyle(to: stopButton, position: .middle)
        applySegmentedStyle(to: homeButton, position: .right)
        
        startPauseButton.onTap = startPauseTapped
        stopButton.onTap = stopTapped
        homeButton.onTap = homeTapped
        
        disableButtons()
        
        addArrangedSubview(startPauseButton)
        addArrangedSubview(stopButton)
        addArrangedSubview(homeButton)
    }
    
    private func setupButton(_ button: UIButton) {
        guard var config = button.configuration else { return }
        config.imagePadding = 6
        config.cornerStyle = .fixed
        config.background.cornerRadius = 0
        button.configuration = config
    }
    
    private enum SegmentPosition {
        case left, middle, right
    }

    private func applySegmentedStyle(to button: UIButton, position: SegmentPosition) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.opaqueSeparator.cgColor
        button.layer.masksToBounds = true
        let radius: CGFloat = 8
        
        switch position {
        case .left:
            button.layer.cornerRadius = radius
            button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .middle:
            button.layer.cornerRadius = 0
            button.layer.maskedCorners = []
        case .right:
            button.layer.cornerRadius = radius
            button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }

    // MARK: - Actions
    
    func disableButtons() {
        isStartPauseEnabled = false
        isStopEnabled = false
        isHomeEnabled = false
    }
    
    private func startPauseTapped() {
        onStartPauseCliked?(isStarted)
    }
    
    private func stopTapped() {
        onStopClicked?()
    }
    
    private func homeTapped() {
        onHomeClicked?()
    }
}




