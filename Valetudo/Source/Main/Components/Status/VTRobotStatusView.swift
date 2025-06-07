//
//  VTRobotStatusView.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

private let imageViewSize: CGSize = CGSize(width: 18, height: 18)

class VTRobotStatusView: UIView {
    
    // MARK: - Subviews
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
                
        let robotType = VTEntityType.robot_position
        let robotIconPath = robotType.icon(center: .zero)
        let robotIcon = robotIconPath?.renderedImage(
            size: imageViewSize,
            strokeColor: UIColor(cgColor: robotType.borderColor!),
            fillColor: UIColor(cgColor: robotType.color!),
            lineWidth: robotType.borderWidth
        )
        
        imageView.image = robotIcon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ROBOT".localizedCapitalized
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let batteryLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let batteryProgressView: VTProgressView = {
        let progressSlider = VTProgressView()
        progressSlider.isUserInteractionEnabled = false
        progressSlider.progressColor = .systemGreen
        progressSlider.trackColor = .systemGray5
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        return progressSlider
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.masksToBounds = false
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        
        setupShadow()

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(batteryLabel)
        addSubview(batteryProgressView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: imageViewSize.width),
            iconImageView.heightAnchor.constraint(equalToConstant: imageViewSize.height),

            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            statusLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 0),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            batteryLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 0),
            batteryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            batteryProgressView.heightAnchor.constraint(equalToConstant: 4),
            batteryProgressView.topAnchor.constraint(equalTo: batteryLabel.bottomAnchor, constant: 4),
            batteryProgressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            batteryProgressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            batteryProgressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configuration
    func update(forStatus status: String, batteryLevel: Double) {
        statusLabel.text = status.uppercased()
        let batteryPercent = Int(batteryLevel)
        batteryLabel.text = "BATTERY".localizedUppercase + ": \(batteryPercent)%"
        batteryProgressView.setProgress(CGFloat(batteryLevel/100), animated: true)
    }
}

