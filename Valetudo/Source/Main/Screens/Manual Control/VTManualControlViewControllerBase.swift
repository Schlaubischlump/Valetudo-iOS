//
//  VTManualControlViewControllerBase.swift
//  Valetudo
//
//  Created by David Klopp on 04.10.25.
//
import UIKit

class VTManualControlViewControllerBase: VTViewController {
    let client: VTAPIClientProtocol
    
    private(set) var ignoreInput: Bool = false
    func withIgnoreInputs(_ closure: @escaping () async throws -> Void) async throws {
        let oldValue = self.ignoreInput
        defer { self.ignoreInput = oldValue }
        self.ignoreInput = true
        try await closure()
    }
    
    private let enableSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()
    
    private lazy var enableSwitchToolbarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(customView: enableSwitch)
        barButton.hidesSharedBackground = true
        return barButton
    }()
    
    func disableAllButtons() {
        // A subclass should disable all elements that allow moving the robot here.
        enableSwitchToolbarButton.isEnabled = false
    }
    
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
        
        setupView()
        
        navigationItem.title = "MANUAL_CONTROL".localizedCapitalized()
        navigationItem.subtitle = "MANUAL_CONTROL_SUBTITLE".localized()
        
        enableSwitch.addTarget(self, action: #selector(didToggleManualControl(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = enableSwitchToolbarButton
        
        disableAllButtons()
    }
    
    func setupView() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { await reconnectAndRefresh() }
    }
    
    func finalizeLoading(manualControlIsEnabled: Bool) {
        enableSwitch.isOn = manualControlIsEnabled
        enableSwitchToolbarButton.isEnabled = true
    }
    
    func enableManualControl() async throws {
        fatalError("enableManualControl must be overriden in a subclass")
    }
    
    func disableManualControl() async throws {
        fatalError("disableManualControl must be overriden in a subclass")
    }
    
    @objc private func didToggleManualControl(_ sender: UISwitch) {
        let isOn = sender.isOn
        disableAllButtons()
        
        Task {
            if (isOn) {
                try? await self.enableManualControl()
            } else {
                try? await self.disableManualControl()
            }
            await reconnectAndRefresh()
        }
    }
}
