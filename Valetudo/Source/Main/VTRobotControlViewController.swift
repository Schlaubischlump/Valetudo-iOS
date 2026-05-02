//
//  VTRobotControlController.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

struct VTFanItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String {
        presetValue.description.capitalized
    }

    var icon: UIImage? {
        switch presetValue {
        case .off: .fanSpeedOff()
        case .low: .fanSpeedLow()
        case .min: .fanSpeedMin()
        case .medium: .fanSpeedMedium()
        case .high: .fanSpeedHigh()
        case .max: .fanSpeedMax()
        case .turbo: .fanSpeedTurbo()
        default: nil
        }
    }
}

struct VTWaterGradeItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String {
        presetValue.description.capitalized
    }

    var icon: UIImage? {
        switch presetValue {
        case .off: .waterGradeOff()
        case .min: .waterGradeMin()
        case .low: .waterGradeLow()
        case .medium: .waterGradeMedium()
        case .high: .waterGradeHigh()
        case .max: .waterGradeMax()
        default: nil
        }
    }
}

struct VTOperationModeItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String {
        presetValue.description.capitalized
    }

    var icon: UIImage? {
        switch presetValue {
        case .vacuum: .fanFill
        case .mop: .dropFill
        case .vacuumAndMop: .operationModeVacuumAndMop
        case .vacuumThenMop: .operationModeVacuumThenMop
        default: nil
        }
    }
}

struct VTRepeatItem: VTSegmentedItem {
    let iterations: Int
    var title: String {
        "× \(iterations)"
    }

    var icon: UIImage? {
        .repeatCount(iterations)
    }

    static func items(in iterationRange: ClosedRange<Int>) -> [VTRepeatItem] {
        Array(iterationRange).map(VTRepeatItem.init)
    }
}

@MainActor
class VTRobotControlViewController: VTViewController {
    enum CleaningConfiguration {
        case full
        case segments(ids: [String], customOrder: Bool, iterations: Int)

        fileprivate var canChangeIterations: Bool {
            switch self {
            case .full: false
            case .segments(ids: _, customOrder: _, iterations: _): true
            }
        }

        fileprivate var iterations: Int {
            switch self {
            case .full: 1
            case .segments(ids: _, customOrder: _, iterations: let iter): iter
            }
        }

        func appending(segmentId: String) -> CleaningConfiguration {
            switch self {
            case .full:
                .segments(ids: [segmentId], customOrder: false, iterations: 1)
            case let .segments(ids: ids, customOrder: order, iterations: iters):
                .segments(ids: ids + [segmentId], customOrder: order, iterations: iters)
            }
        }

        fileprivate func updated(iterations: Int) -> CleaningConfiguration {
            switch self {
            case .full:
                .full
            case .segments(ids: let ids, customOrder: let order, iterations: _):
                .segments(ids: ids, customOrder: order, iterations: iterations)
            }
        }

        func removing(segmentId: String) -> CleaningConfiguration {
            switch self {
            case .full:
                return .full
            case .segments(ids: var ids, customOrder: let order, iterations: let iters):
                let idx = ids.firstIndex(of: segmentId)!
                ids.remove(at: idx)
                if ids.isEmpty {
                    return .full
                } else {
                    return .segments(ids: ids, customOrder: order, iterations: iters)
                }
            }
        }
    }

    /// Cleaning configuration to use when the start button is clicked.
    private var supportsSegmentation: Bool = false
    private var _currentConfiguration: CleaningConfiguration = .full
    var currentConfiguration: CleaningConfiguration {
        get { _currentConfiguration }
        set {
            if supportsSegmentation {
                _currentConfiguration = newValue
            } else {
                _currentConfiguration = .full
            }
            updateIterations()
        }
    }

    private let client: VTAPIClientProtocol
    private var observerToken: VTListenerToken?
    private var sseTask: Task<Void, Never>?
    private var hasConnectedStateAttributesStream = false

    /// Make sure that we process manual UI updates and SSE based UI updates in the right order
    private let serialTaskQueue: SerialTaskQueue = .init()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let startPauseStopControl = VTStartPauseStopControlRow()

    let modeRow = VTSegmentedControlRow<VTOperationModeItem>(
        title: VTPresetType.operationMode.description.capitalized,
        titleIcon: .filemenuAndSelection
    )

    private let fanRow = VTSegmentedControlRow<VTFanItem>(
        title: VTPresetType.fanSpeed.description.capitalized,
        titleIcon: .fanFill
    )
    private let waterRow = VTSegmentedControlRow<VTWaterGradeItem>(
        title: VTPresetType.waterGrade.description.capitalized,
        titleIcon: .dropFill
    )
    private let iterationsRow = VTSegmentedControlRow<VTRepeatItem>(
        title: "ITERATIONS".localized(),
        titleIcon: .repeatSymbol
    )

    private let dockControls = {
        let dockControls = VTStackedControlRow<VTControlButton>(
            title: "CHARGER".localized(),
            titleIcon: .dockArrowDownRectangle
        )
        dockControls.translatesAutoresizingMaskIntoConstraints = false
        dockControls.axis = .horizontal

        let cleanButton = VTToggleControlButton(
            title: "CLEAN".localizedUppercase(),
            icon: .waterWaves
        )
        let dryButton = VTToggleControlButton(
            title: "DRY".localizedUppercase(),
            icon: .heatWavesAndFan
        )
        let emptyButton = VTControlButton(
            title: "EMPTY".localizedUppercase(),
            icon: .arrowUpTrashFill
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
            title: "ATTACHMENTS".localized(),
            titleIcon: .puzzlepieceExtensionFill
        )
        attachmentsControls.axis = .vertical
        attachmentsControls.translatesAutoresizingMaskIntoConstraints = false
        return attachmentsControls
    }()

    private let statisticsControls = {
        let statisticsControls = VTStackedControlRow<VTControlLabel>(
            title: "CURRENT_STATISTICS".localized(),
            titleIcon: .chartBarFill
        )
        statisticsControls.axis = .horizontal
        statisticsControls.translatesAutoresizingMaskIntoConstraints = false
        return statisticsControls
    }()

    init(client: VTAPIClientProtocol) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // view.backgroundColor = .systemBackground
        setupControls()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSSEObservation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopSSEObservation()
    }

    @MainActor
    override func reconnectAndRefresh() async {
        // Cancel existing SSE task and reconnect
        stopSSEObservation()
        startSSEObservation()
    }

    private func startSSEObservation() {
        guard sseTask == nil else { return }

        sseTask = Task {
            do {
                try await loadInitialData()
                hasConnectedStateAttributesStream = false

                let (token, stream) = await client.registerEventObserver(for: .stateAttributes)
                observerToken = token

                for await event in stream {
                    switch event {
                    case .didConnect:
                        if hasConnectedStateAttributesStream {
                            await serialTaskQueue.enqueue { [weak self] in
                                guard let self else { return }
                                guard let attrs = try? await client.getStateAttributes() else { return }
                                await updateButtonStates(attrs)
                                await updateAttachments(attrs)
                                try? await updateStatistics()
                            }
                        } else {
                            hasConnectedStateAttributesStream = true
                        }
                    case let .didReceiveData(attrs):
                        await serialTaskQueue.enqueue { [weak self] in
                            guard let self else { return }
                            await updateButtonStates(attrs)
                            await updateAttachments(attrs)
                            try? await updateStatistics()
                        }
                    case let .didReceiveError(msg):
                        log(message: msg, forSubsystem: .stateAttribute, level: .error)
                        /*showRobotControlError(
                            messageKey: "ROBOT_CONTROL_STATE_ATTRIBUTES_FAILED_MESSAGE",
                            reason: msg
                        )*/
                    default:
                        break
                    }
                }
            } catch {
                log(message: "Failed to update data: \(error.localizedDescription)", forSubsystem: .robotControl, level: .error)
                /*showRobotControlError(
                    messageKey: "ROBOT_CONTROL_INITIAL_LOAD_FAILED_MESSAGE",
                    reason: error.localizedDescription
                )*/
            }
        }
    }

    private func stopSSEObservation() {
        sseTask?.cancel()
        sseTask = nil
        hasConnectedStateAttributesStream = false

        if let token = observerToken {
            let client = client
            Task { await client.removeEventObserver(token: token, for: .stateAttributes) }
            observerToken = nil
        }
    }

    private func showRobotControlError(messageKey: String, reason: String) {
        showError(
            title: "ERROR".localized(),
            message: String(
                format: messageKey.localized(),
                reason
            )
        )
    }

    @MainActor
    func loadInitialData() async throws {
        try await collecting { [weak self] run in
            guard let self else { return }

            await run {
                let capibilities = await Set((try? client.getCapabilities()) ?? [])
                self.supportsSegmentation = capibilities.contains(.mapSegmentation)
                if !self.supportsSegmentation {
                    self.currentConfiguration = .full
                }

                let mapSegmentationProperties: VTMapSegmentationProperties? = if self.supportsSegmentation {
                    try? await self.client.getMapSegmentationProperties()
                } else {
                    nil
                }

                let iterationRange = if let iterationCount = mapSegmentationProperties?.iterationCount {
                    iterationCount.min ... iterationCount.max
                } else {
                    1 ... 1
                }
                self.iterationsRow.values = VTRepeatItem.items(in: iterationRange)
                self.updateIterations()

                self.startPauseStopControl.isHidden = !capibilities.contains(.basicControl)
                self.statisticsControls.isHidden = !capibilities.contains(.currentStatistics)
                self.iterationsRow.isHidden = !capibilities.contains(.mapSegmentation)
                self.emptyButton?.isHidden = !capibilities.contains(.autoEmptyDockManualTrigger)
                self.cleanButton?.isHidden = !capibilities.contains(.mopDockCleanManualTrigger)
                self.dryButton?.isHidden = !capibilities.contains(.mopDockDryManualTrigger)
                self.fanRow.isHidden = !capibilities.contains(.fanSpeedControl)
                self.waterRow.isHidden = !capibilities.contains(.waterUsageControl)
                self.modeRow.isHidden = !capibilities.contains(.operationModeControl)
            }

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
            if let initialAttrs = try? await client.getStateAttributes() {
                await updateButtonStates(initialAttrs)
            }
        }
    }

    @MainActor
    private func updateIterations() {
        let config = currentConfiguration
        iterationsRow.isEnabled = true // allow changes to `selectedValue`
        iterationsRow.subtitle = "x \(config.iterations)"
        iterationsRow.selectedValue = VTRepeatItem(iterations: config.iterations)
        iterationsRow.isEnabled = config.canChangeIterations
    }

    @MainActor
    private func updateStatistics() async throws {
        let currentStatistics = try await client.getCurrentStatisticsCapability()
        await updateStatistics(currentStatistics)
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
    private func updateButtonStates(_ state: VTStateAttributeList) async {
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

        let robotIsDocked = state.isDocked
        let mopPadsAreAttached = state.mopPadsAreAttached
        let dockIsReady = state.dockIsReady
        let isDryingMopPads = state.isDryingMopPads
        let isCleaningMopPads = state.isCleaningMopPads

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
    private func updateAttachments(_ state: VTStateAttributeList) async {
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
            if isStarted {
                try await client.pause()
            } else {
                switch currentConfiguration {
                case .full:
                    try await client.start()
                case let .segments(ids: ids, customOrder: order, iterations: iters):
                    try await client.clean(segmentIDs: ids, customOrder: order, iterations: iters)
                }
            }
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_START_PAUSE_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    private func stop() async {
        do {
            try await client.stop()
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_STOP_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    private func home() async {
        do {
            try await client.home()
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_HOME_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    private func changeFanSpeed(old _: VTPresetValue?, new value: VTPresetValue) async {
        do {
            try await client.setPreset(value, forType: .fanSpeed)
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_FAN_SPEED_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    private func changeWaterGrade(old _: VTPresetValue?, new value: VTPresetValue) async {
        do {
            try await client.setPreset(value, forType: .waterGrade)
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_WATER_GRADE_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    private func changeOperationMode(old _: VTPresetValue?, new value: VTPresetValue) async {
        do {
            try await client.setPreset(value, forType: .operationMode)
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_OPERATION_MODE_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    @MainActor
    private func dryMopPads() async {
        do {
            let attrs = try await client.getStateAttributes()
            if attrs.isDryingMopPads {
                try await client.stopMopDockDry()
            } else {
                try await client.startMopDockDry()
            }
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_DRY_MOP_PADS_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    @MainActor
    private func cleanMopPads() async {
        do {
            let attrs = try await client.getStateAttributes()
            if attrs.isCleaningMopPads {
                try await client.stopMopDockClean()
            } else {
                try await client.startMopDockClean()
            }
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_CLEAN_MOP_PADS_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
        }
    }

    @MainActor
    private func emptyDock() async {
        do {
            try await client.autoEmptyDock()
        } catch {
            await updateButtons()
            log(message: error.localizedDescription, forSubsystem: .robotControl, level: .error)
            showRobotControlError(
                messageKey: "ROBOT_CONTROL_EMPTY_DOCK_FAILED_MESSAGE",
                reason: error.localizedDescription
            )
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

        fanRow.onValueChanged = { [weak self] old, new in
            self?.fanRow.isEnabled = false
            Task { await self?.changeFanSpeed(old: old?.presetValue, new: new.presetValue) }
        }
        waterRow.onValueChanged = { [weak self] old, new in
            self?.waterRow.isEnabled = false
            Task { await self?.changeWaterGrade(old: old?.presetValue, new: new.presetValue) }
        }
        modeRow.onValueChanged = { [weak self] old, new in
            self?.modeRow.isEnabled = false
            Task { await self?.changeOperationMode(old: old?.presetValue, new: new.presetValue) }
        }
        iterationsRow.onValueChanged = { [weak self] _, new in
            let config = self?.currentConfiguration ?? .full
            self?.currentConfiguration = config.updated(iterations: new.iterations)
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
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16
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
            ),
        ])

        contentStackView.addArrangedSubview(startPauseStopControl)
        contentStackView.addArrangedSubview(modeRow)
        contentStackView.addArrangedSubview(fanRow)
        contentStackView.addArrangedSubview(waterRow)
        contentStackView.addArrangedSubview(iterationsRow)
        contentStackView.addArrangedSubview(dockControls)
        contentStackView.addArrangedSubview(attachmentsControls)
        contentStackView.addArrangedSubview(statisticsControls)
    }
}
