//
//  VTRobotCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 23.04.26.
//
import UIKit

final class VTRobotCellContentView: UIView, UIContentView {
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "robotic.vacuum.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let serviceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()

    private var currentConfiguration: VTRobotCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? VTRobotCellContentConfiguration else { return }
            currentConfiguration = configuration
            apply(configuration)
        }
    }

    init(configuration: VTRobotCellContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setupViews()
        apply(configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, serviceLabel, idLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.alignment = .fill
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [iconView, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 14
        contentStack.alignment = .top
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func apply(_ configuration: VTRobotCellContentConfiguration) {
        let robot = configuration.robot
        titleLabel.text = robot.name
        subtitleLabel.text = Self.subtitle(for: robot)
        serviceLabel.text = "SERVICE".localized() + ": \(robot.serviceName)"
        idLabel.text = "ID".localized() + " : \(robot.id)"
    }

    private static func subtitle(for robot: VTMDNSRobot) -> String {
        let modelParts = [robot.manufacturer, robot.model]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        let model = modelParts.isEmpty ? "UNKNOWN_MODEL".localized() : modelParts.joined(separator: " ")
        guard let version = robot.version, !version.isEmpty else { return model }
        return "\(model) · " + "VALETUDO".localized() + " \(version)"
    }
}
