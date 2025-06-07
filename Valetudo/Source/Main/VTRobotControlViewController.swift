//
//  VTRobotControlController.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

struct VTFanItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String { presetValue.description.capitalized }
    var icon: UIImage? {
        switch presetValue {
        case .off:      .fanSpeedOff()
        case .low:      .fanSpeedLow()
        case .min:      .fanSpeedMin()
        case .medium:   .fanSpeedMedium()
        case .high:     .fanSpeedHigh()
        case .max:      .fanSpeedMax()
        case .turbo:    .fanSpeedTurbo()
        default: nil
        }
    }
}

struct VTWaterGradeItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String { presetValue.description.capitalized }
    var icon: UIImage? {
        switch presetValue {
        case .off:      .waterGradeOff()
        case .min:      .waterGradeMin()
        case .low:      .waterGradeLow()
        case .medium:   .waterGradeMedium()
        case .high:     .waterGradeHigh()
        case .max:      .waterGradeMax()
        default: nil
        }
        
    }
}

struct VTOperationModeItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String { presetValue.description.capitalized }
    var icon: UIImage? {
        guard let fanImage = UIImage(systemName: "fan.fill"),
              let waterImage = UIImage(systemName: "drop.fill") else { return nil }
        return switch presetValue {
        case .vacuum:           fanImage
        case .mop:              waterImage
        case .vacuumAndMop:     UIImage.combine(left: waterImage, right: fanImage)
        case .vacuumThenMop:    nil
        default: nil
        }
    }
}


class VTRobotControlViewController: UIViewController {
    
    enum CleaningConfiguration {
        case none
        case segments(ids: [String], customOrder: Bool, iterations: Int)
        
        public func appending(segmentId: String) -> CleaningConfiguration {
            switch (self) {
            case .none:
                return .segments(ids: [segmentId], customOrder: false, iterations: 1)
            case .segments(ids: let ids, customOrder: let order, iterations: let iters):
                return .segments(ids: ids + [segmentId], customOrder: order, iterations: iters)
            }
        }
        
        public func removing(segmentId: String) -> CleaningConfiguration {
            switch (self) {
            case .none:
                return .none
            case .segments(ids: var ids, customOrder: let order, iterations: let iters):
                let idx = ids.firstIndex(of: segmentId)!
                ids.remove(at: idx)
                if (ids.isEmpty) {
                    return .none
                } else {
                    return .segments(ids: ids, customOrder: order, iterations: iters)
                }
            }
        }
    }
    
    /// Cleaning configuration to use when the start button is clicked.
    var currentConfiguration: CleaningConfiguration = .none
    
    private let client: VTAPIClientProtocol
    private var observerToken: VTListenerToken?
    
    // Make sure that we process manual UI updates and SSE based UI updates in the right order
    private let serialTaskQueue: SerialTaskQueue = SerialTaskQueue()
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let startPauseStopControl = VTStartPauseStopControlRow()

    // TODO: Add cleaning times?
    
    let modeRow = VTSegmentedControlRow<VTOperationModeItem>(
        title: VTPresetType.operationMode.description.capitalized,
        titleIcon: UIImage(systemName: "filemenu.and.selection")
    )
    
    private let fanRow = VTSegmentedControlRow<VTFanItem>(
        title: VTPresetType.fanSpeed.description.capitalized,
        titleIcon: UIImage(systemName: "fan.fill"),
    )
    private let waterRow = VTSegmentedControlRow<VTWaterGradeItem>(
        title: VTPresetType.waterGrade.description.capitalized,
        titleIcon: UIImage(systemName: "drop.fill"),
    )

    private let dockControls = {
        let dockControls = VTStackedControlRow<VTControlButton>(
            title: "CHARGER".localizedCapitalized,
            titleIcon: UIImage(systemName: "dock.arrow.down.rectangle")
        )
        dockControls.translatesAutoresizingMaskIntoConstraints = false
        dockControls.axis = .horizontal
        
        // TODO: Conditionally add these items based on the Capability of the robot
        let cleanButton = VTToggleControlButton(
            title: "CLEAN".localizedUppercase,
            icon: UIImage(systemName: "water.waves")
        )
        let dryButton = VTToggleControlButton(
            title: "DRY".localizedUppercase,
            icon: UIImage(systemName: "heat.waves.and.fan")
        )
        let emptyButton = VTControlButton(
            title: "EMPTY".localizedUppercase,
            icon: UIImage(systemName: "arrow.up.trash.fill")
        )

        cleanButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dryButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emptyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dockControls.items = [cleanButton, dryButton, emptyButton]
        return dockControls
    }()
    
    private var cleanButton: VTToggleControlButton? {
        dockControls.items.first as? VTToggleControlButton
    }
    private var dryButton: VTToggleControlButton? {
        dockControls.items.count >= 2 ? dockControls.items[1] as? VTToggleControlButton : nil
    }
    private var emptyButton: VTControlButton? {
        dockControls.items.count >= 3 ? dockControls.items[2] : nil
    }
    
    private let attachmentsControls = {
        let attachmentsControls = VTStackedControlRow<VTControlButton>(
            title: "ATTACHMENTS".localizedCapitalized,
            titleIcon: UIImage(systemName: "puzzlepiece.extension.fill")
        )
        attachmentsControls.axis = .vertical
        attachmentsControls.translatesAutoresizingMaskIntoConstraints = false
        return attachmentsControls
    }()
    
    private let statisticsControls = {
        let statisticsControls = VTStackedControlRow<VTControlLabel>(
            title: "CURRENT_STATISTICS".localizedCapitalized,
            titleIcon: UIImage(systemName: "chart.bar.fill")
        )
        statisticsControls.axis = .horizontal
        statisticsControls.translatesAutoresizingMaskIntoConstraints = false
        return statisticsControls
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
        setupControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                try await loadInitialData()
                
                let (token, stream) = await client.registerEventObserver(for: .stateAttributes)
                observerToken = token
                
                for await event in stream {
                    switch event {
                    case .didReceiveData(let attrs):
                        await serialTaskQueue.enqueue { [weak self] in
                            guard let self else { return }
                            await updateButtonStates(attrs)
                            await updateAttachments(attrs)
                            try? await updateStatistics()
                        }
                    case .didReceiveError(let msg):
                        print("Received error message: \(msg)")
                        // TODO: Handle error
                    default:
                        break
                    }
                }
            } catch {
                // TODO: Do something with the error
                print("Failed to update data: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let token = observerToken {
            // capture a strong reference, since we know the client will outlive self
            let client = self.client
            Task { await client.removeEventObserver(token: token, for: .map) }
        }
    }
    
    @MainActor
    func loadInitialData() async throws {
        try await collecting { [weak self] run in
            guard let self else { return }
            await run {
                self.fanRow.values = try await self.client.getPresets(forType: .fanSpeed)
                    .map(VTFanItem.init)
                self.waterRow.values = try await self.client.getPresets(forType: .waterGrade)
                    .map(VTWaterGradeItem.init)
                self.modeRow.values = try await self.client.getPresets(forType: .operationMode)
                    .map(VTOperationModeItem.init)
            }
            await run {
                try await self.updateStatistics()
            }
            await run {
                let initialAttrs = try await self.client.getStateAttributes()
                await self.updateButtonStates(initialAttrs)
                await self.updateAttachments(initialAttrs)
            }
        }
    }
    
    @MainActor
    private func updateButtons() async {
        await serialTaskQueue.enqueue { [weak self] in
            guard let self else { return }
            if let initialAttrs = try? await self.client.getStateAttributes() {
                await self.updateButtonStates(initialAttrs)
            }
        }
    }
    
    @MainActor
    private func updateStatistics() async throws {
        let currentStatistics = try await client.getCurrentStatisticsCapability()
        await self.updateStatistics(currentStatistics)
    }
    
    @MainActor
    private func updateStatistics(_ statistics: [VTValetudoDataPoint]) async {
        // update all statistics
        statisticsControls.items = statistics.map { dataPoint in
            let label = VTControlLabel(
                title: dataPoint.type.description.capitalized,
                subtitle: dataPoint.description
            )
            label.heightAnchor.constraint(equalToConstant: 50).isActive = true
            return label
        }
    }
    
    @MainActor
    private func updateButtonStates(_ state: VTStateAttributes) async {
        startPauseStopControl.isStopEnabled = state.isStoppable
        startPauseStopControl.isHomeEnabled = state.canReturnHome
        if state.isStarted {
            startPauseStopControl.isStarted = true
            startPauseStopControl.isStartPauseEnabled = true
        } else if state.isPaused {
            startPauseStopControl.isStarted = false
            startPauseStopControl.isStartPauseEnabled = true
        } else {
            // Might happen if e.g. robot is manually controlled
            startPauseStopControl.isStarted = false
            startPauseStopControl.isStartPauseEnabled = false
        }
        
        let robotIsDocked      = state.isDocked
        let mopPadsAreAttached = state.mopPadsAreAttached
        let dockIsReady        = state.dockIsReady
        let isDryingMopPads    = state.isDryingMopPads
        let isCleaningMopPads  = state.isCleaningMopPads
        
        print("Dry mop pads: \(isDryingMopPads) \(state.isDocked) \(String(describing: state.statusStateAttributes.first!.value))")
        
        dryButton?.isEnabled = robotIsDocked && mopPadsAreAttached && (dockIsReady || isDryingMopPads)
        dryButton?.isToggled = isDryingMopPads
        
        cleanButton?.isEnabled = robotIsDocked && mopPadsAreAttached && (dockIsReady || isCleaningMopPads)
        cleanButton?.isToggled = isCleaningMopPads
        
        emptyButton?.isEnabled = robotIsDocked
        
        fanRow.subtitle = state.fanSpeed.description.capitalized
        fanRow.selectedValue = VTFanItem(presetValue: state.fanSpeed)
        fanRow.isEnabled = true
        
        waterRow.subtitle = state.waterGrade.description.capitalized
        waterRow.selectedValue = VTWaterGradeItem(presetValue: state.waterGrade)
        waterRow.isEnabled = true
        
        modeRow.subtitle = state.operationMode.description.capitalized
        modeRow.selectedValue = VTOperationModeItem(presetValue: state.operationMode)
        modeRow.isEnabled = true
    }
    
    @MainActor
    private func updateAttachments(_ state: VTStateAttributes) async {
        // update all attachments
        attachmentsControls.items = state.attachmendTypes.map { attachmentType in
            let button = VTControlButton(
                title: attachmentType.description.uppercased(),
                icon: nil
            )
            button.isEnabled = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            return button
        }
    }

    private func toggleStartPause(isStarted: Bool) async {
        do {
            if (isStarted) {
                try await client.pause()
            } else {
                switch (currentConfiguration) {
                case .none:
                    try await client.start()
                case .segments(ids: let ids, customOrder: let order, iterations: let iters):
                    try await client.clean(segmentIDs: ids, customOrder: order, iterations: iters)
                }
            }
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    private func stop() async {
        do {
            try await client.stop()
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    private func home() async {
        do {
            try await client.home()
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    private func changeFanSpeed(old: VTPresetValue?, new value: VTPresetValue) async {
        do {
            try await self.client.setPreset(value, forType: .fanSpeed)
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    private func changeWaterGrade(old: VTPresetValue?, new value:  VTPresetValue) async {
        do {
            try await self.client.setPreset(value, forType: .waterGrade)
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    private func changeOperationMode(old: VTPresetValue?, new value: VTPresetValue) async {
        do {
            try await self.client.setPreset(value, forType: .operationMode)
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    @MainActor
    private func dryMopPads() async {
        do {
            let attrs = try await self.client.getStateAttributes()
            if attrs.isDryingMopPads {
                try await client.stopMopDockDry()
            } else {
                try await client.startMopDockDry()
            }
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    @MainActor
    private func cleanMopPads() async {
        do {
            let attrs = try await self.client.getStateAttributes()
            if attrs.isCleaningMopPads {
                try await client.stopMopDockClean()
            } else {
                try await client.startMopDockClean()
            }
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    @MainActor
    private func emptyDock() async {
        do {
            try await client.autoEmptyDock()
        } catch {
            await updateButtons()
            // TODO: Show error
        }
    }
    
    private func setupControls() {
        startPauseStopControl.onStartPauseCliked = { [weak self] isStarted in
            self?.startPauseStopControl.disableButtons()
            Task { await self?.toggleStartPause(isStarted: isStarted) }
        }
        startPauseStopControl.onStopClicked = { [weak self] in
            self?.startPauseStopControl.disableButtons()
            Task { await self?.stop() }
        }
        startPauseStopControl.onHomeClicked = { [weak self] in
            self?.startPauseStopControl.disableButtons()
            Task { await self?.home() }
        }
        
        dryButton?.onTap = { [weak self] in
            self?.dockControls.isEnabled = false
            Task { await self?.dryMopPads() }
        }
        cleanButton?.onTap = { [weak self] in
            self?.dockControls.isEnabled = false
            Task { await self?.cleanMopPads() }
        }
        emptyButton?.onTap = { [weak self] in
            self?.dockControls.isEnabled = false
            Task { await self?.emptyDock() }
        }
        
        fanRow.onValueChanged = { [weak self] (old, new) in
            self?.fanRow.isEnabled = false
            Task { await self?.changeFanSpeed(old: old?.presetValue, new: new.presetValue) }
        }
        waterRow.onValueChanged = { [weak self] (old, new) in
            self?.waterRow.isEnabled = false
            Task { await self?.changeWaterGrade(old: old?.presetValue, new: new.presetValue) }
        }
        modeRow.onValueChanged = { [weak self] (old, new) in
            self?.modeRow.isEnabled = false
            Task { await self?.changeOperationMode(old: old?.presetValue, new: new.presetValue) }
        }
        
        scrollView.delaysContentTouches = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 30
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20
            ),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32
            )
        ])
        
        contentStackView.addArrangedSubview(startPauseStopControl)
        contentStackView.addArrangedSubview(modeRow)
        contentStackView.addArrangedSubview(fanRow)
        contentStackView.addArrangedSubview(waterRow)
        contentStackView.addArrangedSubview(dockControls)
        contentStackView.addArrangedSubview(attachmentsControls)
        contentStackView.addArrangedSubview(statisticsControls)
    }
}
