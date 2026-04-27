//
//  VTStartPauseStopControl.swift
//  Valetudo
//
//  Created by David Klopp on 23.05.25.
//
import UIKit

final class VTStartPauseStopControlRow: UIStackView {
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

    private var startPauseButton = VTControlButton(title: nil, icon: .playFill)
    private var stopButton = VTControlButton(title: nil, icon: .stopFill)
    private var homeButton = VTControlButton(title: nil, icon: .houseFill)

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
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true

        setupButton(startPauseButton)
        setupButton(stopButton)
        setupButton(homeButton)

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

    override func layoutSubviews() {
        super.layoutSubviews()
        applySegmentedStyle(to: startPauseButton, position: .left)
        applySegmentedStyle(to: stopButton, position: .middle)
        applySegmentedStyle(to: homeButton, position: .right)
    }

    private func applySegmentedStyle(to button: UIButton, position: SegmentPosition) {
        let radius: CGFloat = button.frame.height / 2
        let (roundedCorners, borderEdge): (UIRectCorner, UIRectEdge) = switch position {
        case .left: ([.topLeft, .bottomLeft], [.right])
        case .middle: ([], [])
        case .right: ([.topRight, .bottomRight], [.left])
        }

        let path = UIBezierPath(
            roundedRect: button.bounds,
            byRoundingCorners: roundedCorners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        button.layer.mask = mask
        button.updateBorder(edge: borderEdge, color: .opaqueSeparator.withAlphaComponent(0.5), thickness: 1.0)
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
