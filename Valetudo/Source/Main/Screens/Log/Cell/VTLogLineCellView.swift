//
//  VTLogLineCellView.swift
//  Valetudo
//
//  Created by David Klopp on 05.10.25.
//
import UIKit

final class VTLogLineCellView: UIView, UIContentView {

    private var currentConfiguration: VTLogLineCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? VTLogLineCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let timestampLabel = UILabel()
    private let levelLabel = UILabel()
    private let messageLabel = UILabel()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = .current
        f.timeZone = .current
        return f
    }()

    init(configuration: VTLogLineCellContentConfiguration) {
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
        setupContextMenu()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        isUserInteractionEnabled = true
    }

    private func setupViews() {
        timestampLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        timestampLabel.textColor = .secondaryLabel

        levelLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        levelLabel.textAlignment = .right

        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .fill
        topStack.alignment = .firstBaseline
        topStack.spacing = 8
        topStack.addArrangedSubview(timestampLabel)
        topStack.addArrangedSubview(levelLabel)
        topStack.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .label

        let vStack = UIStackView(arrangedSubviews: [topStack, messageLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(vStack)
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: vStack.topAnchor),
            topStack.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            topStack.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            topStack.heightAnchor.constraint(equalToConstant: 20),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        layer.cornerRadius = 8
        clipsToBounds = true
    }

    private func apply(configuration: VTLogLineCellContentConfiguration) {
        currentConfiguration = configuration

        timestampLabel.text = Self.dateFormatter.string(from: configuration.timestamp)
        levelLabel.text = configuration.level.capitalized
        messageLabel.text = configuration.message

        levelLabel.textColor = switch configuration.level.lowercased() {
        case "error": .systemRed
        case "warn":  .systemYellow
        case "info":  .systemGreen
        case "debug": .systemTeal
        case "trace": .systemIndigo
        default: .secondaryLabel
        }
    }
}

extension VTLogLineCellView: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let text = "[\(timestampLabel.text ?? "")] [\(levelLabel.text ?? "")] \(messageLabel.text ?? "")]"
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let title = "COPY".localized()
            let copyAction = UIAction(title: title, image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = text
            }
            return UIMenu(title: "", children: [copyAction])
        }
    }
}
