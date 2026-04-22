//
//  VTLaunchScreenViewController.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import UIKit

final class VTLaunchScreenViewController: UIViewController {
    private var iconBackgroundConstraints: [NSLayoutConstraint] = []
    private var isAnimatingDismissal = false

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.54, green: 0.80, blue: 0.91, alpha: 1.0)
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let floorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.10)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let robotView: VTRobotVacuumView = {
        let view = VTRobotVacuumView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = UIApplication.shared.displayName
        label.textAlignment = .center
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .largeTitle).withWeight(.semibold)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureHierarchy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isAnimatingDismissal else { return }
        iconBackgroundView.layer.cornerRadius = min(iconBackgroundView.bounds.width, iconBackgroundView.bounds.height) * 0.18
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRobotAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        robotView.stopAnimatingBrushes()
    }

    private func configureHierarchy() {
        view.addSubview(iconBackgroundView)
        view.addSubview(floorLineView)
        view.addSubview(robotView)
        view.addSubview(titleLabel)

        iconBackgroundConstraints = [
            iconBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28),
            iconBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.46),
            iconBackgroundView.heightAnchor.constraint(equalTo: iconBackgroundView.widthAnchor, multiplier: 0.72),
            iconBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 360),
            iconBackgroundView.widthAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ]

        NSLayoutConstraint.activate(iconBackgroundConstraints + [
            robotView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            robotView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28),
            robotView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3312),
            robotView.widthAnchor.constraint(lessThanOrEqualToConstant: 259.2),
            robotView.widthAnchor.constraint(greaterThanOrEqualToConstant: 129.6),
            robotView.heightAnchor.constraint(equalTo: robotView.widthAnchor, multiplier: 0.92),

            floorLineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floorLineView.centerYAnchor.constraint(equalTo: robotView.bottomAnchor, constant: -8),
            floorLineView.widthAnchor.constraint(equalTo: robotView.widthAnchor, multiplier: 0.58),
            floorLineView.heightAnchor.constraint(equalToConstant: 4),

            titleLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func animateDismiss(completion: @escaping () -> Void) {
        view.layoutIfNeeded()
        isAnimatingDismissal = true

        let currentFrame = iconBackgroundView.frame
        NSLayoutConstraint.deactivate(iconBackgroundConstraints)
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = true
        iconBackgroundView.frame = currentFrame
        view.insertSubview(iconBackgroundView, belowSubview: floorLineView)

        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.92,
            initialSpringVelocity: 0.15,
            options: [.curveEaseInOut, .allowAnimatedContent]
        ) {
            self.iconBackgroundView.frame = self.view.bounds
            self.iconBackgroundView.layer.cornerRadius = 0
            self.iconBackgroundView.layer.shadowOpacity = 0
            self.titleLabel.alpha = 0
        } completion: { _ in
            self.robotView.stopAnimatingBrushes()
            completion()
        }
    }

    private func startRobotAnimation() {
        robotView.startAnimatingBrushes()
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
