//
//  VTManualControlView.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//
import UIKit

final class VTManualControlViewController: VTManualControlViewControllerBase {
    private func makeButton(systemName: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .secondaryLabel
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: systemName)
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private lazy var upButton    = makeButton(systemName: "arrow.up", action: #selector(didTapUp))
    private lazy var downButton  = makeButton(systemName: "arrow.down", action: #selector(didTapDown))
    private lazy var leftButton  = makeButton(systemName: "arrow.counterclockwise", action: #selector(didTapLeft))
    private lazy var rightButton = makeButton(systemName: "arrow.clockwise", action: #selector(didTapRight))
    
    private lazy var gridStack: UIStackView = {
        let grid = UIStackView()
        grid.axis = .horizontal
        grid.spacing = 20
        grid.distribution = .equalCentering
        grid.alignment = .center
        grid.translatesAutoresizingMaskIntoConstraints = false
        
        // Left column: rotate left
        let leftCol = UIStackView(arrangedSubviews: [leftButton])
        leftCol.axis = .vertical
        leftCol.alignment = .center
        
        // Middle column: up + down stacked
        let middleCol = UIStackView(arrangedSubviews: [upButton, downButton])
        middleCol.axis = .vertical
        middleCol.spacing = 20
        middleCol.alignment = .center
        
        // Right column: rotate right
        let rightCol = UIStackView(arrangedSubviews: [rightButton])
        rightCol.axis = .vertical
        rightCol.alignment = .center
        
        grid.addArrangedSubview(leftCol)
        grid.addArrangedSubview(middleCol)
        grid.addArrangedSubview(rightCol)
        
        return grid
    }()
    
    override func disableAllButtons() {
        upButton.isEnabled    = false
        downButton.isEnabled  = false
        leftButton.isEnabled  = false
        rightButton.isEnabled = false
        super.disableAllButtons()
    }
    
    override func setupView() {
        super.setupView()
        
        // Add grid
        view.addSubview(gridStack)
        
        let gridStackWidth  = 80.0 * 3 + gridStack.spacing * 2.0
        let gridStackHeight = 80.0 * 2 + gridStack.spacing
        NSLayoutConstraint.activate([
            gridStack.widthAnchor.constraint(equalToConstant: gridStackWidth),
            gridStack.heightAnchor.constraint(equalToConstant: gridStackHeight),
            gridStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            gridStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        [upButton, downButton, leftButton, rightButton].forEach {
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }
    }
    
    @MainActor
    override func reconnectAndRefresh() async {        
        let isEnabled = (try? await client.getManualControlIsEnabled()) ?? false
        
        if (isEnabled) {
            let supportedMovementDirections = (try? await client.getManualControlSupportedMovementDirections()) ?? []
            supportedMovementDirections.forEach {
                switch ($0) {
                case .forward:                downButton.isEnabled  = true
                case .backward:               upButton.isEnabled    = true
                case .rotateClockwise:        rightButton.isEnabled = true
                case .rotateCounterclockwise: leftButton.isEnabled  = true
                }
            }
        }
        finalizeLoading(manualControlIsEnabled: isEnabled)
    }
    
    // MARK: - Actions
    
    override func enableManualControl() async throws {
        try await client.enableManualControl()
    }
    
    override func disableManualControl() async throws {
        try await client.disableManualControl()
    }
    
    @objc private func didTapUp() {
        guard !ignoreInput else { return }
        Task {
            try await withIgnoreInputs { [weak self] in
                try await self?.client.manualControlMove(direction: .forward)
            }
        }
    }
    
    @objc private func didTapDown() {
        guard !ignoreInput else { return }
        Task {
            try await withIgnoreInputs { [weak self] in
                try await self?.client.manualControlMove(direction: .backward)
            }
        }
    }
    
    @objc private func didTapLeft() {
        guard !ignoreInput else { return }
        Task {
            try await withIgnoreInputs { [weak self] in
                try await self?.client.manualControlMove(direction: .rotateCounterclockwise)
            }
        }
    }
    
    @objc private func didTapRight() {
        guard !ignoreInput else { return }
        Task {
            try await withIgnoreInputs { [weak self] in
                try await self?.client.manualControlMove(direction: .rotateClockwise)
            }
        }
    }
}


