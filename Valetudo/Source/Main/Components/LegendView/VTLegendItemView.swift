//
//  VTLegendItemView.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

class VTLegendItemView: UIView {

    private let colorView = UIView()
    private let legendLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    var isSelected: Bool = false {
        didSet {
            updateCheckmark()
        }
    }

    init(item: VTLegendItem) {
        super.init(frame: .zero)
        setup(item: item)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.masksToBounds = false
    }
    
    private func setup(item: VTLegendItem) {
        backgroundColor = .systemGray6
        
        setupShadow()

        // Color view
        colorView.backgroundColor = item.color
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 24),
            colorView.heightAnchor.constraint(equalToConstant: 24)
        ])

        // Label
        legendLabel.text = item.text
        legendLabel.font = .systemFont(ofSize: 14)
        legendLabel.textColor = .label

        // Checkmark
        checkmarkImageView.tintColor = .tintColor
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])

        updateCheckmark() // Initial state

        // Stack
        let stack = UIStackView(arrangedSubviews: [colorView, legendLabel, checkmarkImageView])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorView.layoutIfNeeded()
        colorView.layer.cornerRadius = colorView.bounds.height / 2
        layer.cornerRadius = bounds.height / 2
    }

    private func updateCheckmark() {
        let imageName = isSelected ? "checkmark.circle.fill" : "circle"
        let symbolImage = UIImage(systemName: imageName)
        
        // Animate the image change with crossfade
        UIView.transition(with: checkmarkImageView,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: { [weak self] in
                              self?.checkmarkImageView.image = symbolImage
                          },
                          completion: nil)
    }
}
