//
//  VTManualControlView.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//
import UIKit

final class VTManualControlViewController: UIViewController {
    private let client: VTAPIClientProtocol
    
    private let enableSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()
    
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
    
    init(client: VTAPIClientProtocol) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
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
        
        navigationItem.title = "MANUAL_CONTROL".localizedCapitalized()
        navigationItem.subtitle = "MANUAL_CONTROL_SUBTITLE".localizedCapitalized()
        
        enableSwitch.addTarget(self, action: #selector(didToggleManualControl(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: enableSwitch)
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.hidesSharedBackground = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { await loadInitialData() }
    }
    
    @MainActor
    func loadInitialData() async {
        // TODO: load stuff
        
        enableSwitch.isOn = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: - Actions
    
    @objc private func didTapUp() {
        print("Up button tapped")
    }
    
    @objc private func didTapDown() {
        print("Down button tapped")
    }
    
    @objc private func didTapLeft() {
        print("Left rotate tapped")
    }
    
    @objc private func didTapRight() {
        print("Right rotate tapped")
    }
    
    @objc private func didToggleManualControl(_ sender: UISwitch) {
        print("Manual control \(sender.isOn ? "enabled" : "disabled")")
    }
}


