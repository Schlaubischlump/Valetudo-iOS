//
//  VTStartPauseStopControl.swift
//  Valetudo
//
//  Created by David Klopp on 23.05.25.
//
import UIKit

final class VTStartPauseStopControlRow: UIView {
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

    private let buttonContainerView = UIView()
    private let startPauseButton = VTControlButton(title: nil, icon: .playFill)
    private let stopButton = VTControlButton(title: nil, icon: .stopFill)
    private let homeButton = VTControlButton(title: nil, icon: .houseFill)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true

        buttonContainerView.isUserInteractionEnabled = true
        buttonContainerView.clipsToBounds = true
        addSubview(buttonContainerView)

        setupButton(startPauseButton)
        setupButton(stopButton)
        setupButton(homeButton)

        startPauseButton.onTap = startPauseTapped
        stopButton.onTap = stopTapped
        homeButton.onTap = homeTapped

        [startPauseButton, stopButton, homeButton].forEach {
            buttonContainerView.addSubview($0)
        }

        disableButtons()
    }

    private func setupButton(_ button: UIButton) {
        guard var config = button.configuration else { return }
        config.imagePadding = 6
        config.cornerStyle = .fixed
        config.background.cornerRadius = 0
        config.background.backgroundInsets = .zero
        // config.background.visualEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark), style: .fill)
        button.configuration = config
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Force the visible strip to use a width divisible by 3 so each button gets an
        // exact third. That avoids fractional button widths and the visual glitches they cause on macOS.
        let snappedWidth = snappedControlWidth(for: bounds.width)
        let alignedOriginX = (bounds.width - snappedWidth) / 2
        let height = bounds.height
        let buttonWidth = snappedWidth / 3

        buttonContainerView.frame = CGRect(x: alignedOriginX, y: 0, width: snappedWidth, height: height)
        buttonContainerView.layer.cornerRadius = height / 2

        startPauseButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: height)
        stopButton.frame = CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: height)
        homeButton.frame = CGRect(x: buttonWidth * 2, y: 0, width: buttonWidth, height: height)

        // Add a left and right border on the middle button.
        stopButton.updateBorder(edge: [.left, .right], color: .opaqueSeparator.withAlphaComponent(0.5), thickness: 1.0)
    }

    private func snappedControlWidth(for availableWidth: CGFloat) -> CGFloat {
        // Round down to the nearest multiple of 3 to keep all three button widths whole.
        max(0, floor(availableWidth / 3) * 3)
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
