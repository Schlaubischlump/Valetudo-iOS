//
//  VTProgressView.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

/// ProgressView is not working on macOS catalyst.
/// In particular, you can not change its color.
/// Therefore we implement this custom class.
class VTProgressView: UIView {
    /// Progress value between 0.0 and 1.0
    var progress: CGFloat = 0 {
        didSet {
            progress = min(max(progress, 0), 1)
            setNeedsLayout()
        }
    }

    var progressColor: UIColor = .systemBlue {
        didSet {
            progressBar.backgroundColor = progressColor
        }
    }

    var trackColor: UIColor = .systemGray5 {
        didSet {
            backgroundView.backgroundColor = trackColor
        }
    }

    private let backgroundView = UIView()
    private let progressBar = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = 2

        backgroundView.backgroundColor = trackColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        progressBar.backgroundColor = progressColor
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressBar)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let progressWidth = bounds.width * progress
        progressBar.frame = CGRect(x: 0, y: 0, width: progressWidth, height: bounds.height)
    }

    func setProgress(_ value: CGFloat, animated: Bool = true, duration: TimeInterval = 0.25) {
        let clamped = min(max(value, 0), 1)
        if animated {
            UIView.animate(withDuration: duration) {
                self.progress = clamped
            }
        } else {
            progress = clamped
        }
    }
}
