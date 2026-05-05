//
//  VTRobotControlController.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

/// Maps the robot's current activity to UI-specific control state.
private enum VTActiveRobotAction {
    case segment
    case zone
    case goTo
    case mapping

    var badgeImage: UIImage? {
        switch self {
        case .segment: .segmentedCleanup
        case .zone: .zoneCleanup
        case .goTo: .goToLocation
        case .mapping: .mappingPass
        }
    }

    var controlMode: VTRobotControlMode? {
        switch self {
        case .segment: .segment
        case .zone: .zone
        case .goTo: .goTo
        case .mapping: nil
        }
    }
}

/// Segmented-control item used to present fan speed presets.
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

/// Segmented-control item used to present water grade presets.
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

/// Segmented-control item used to present operation mode presets.
struct VTOperationModeItem: VTSegmentedItem {
    let presetValue: VTPresetValue
    var title: String {
        presetValue.description.capitalized
    }

    var icon: UIImage? {
        switch presetValue {
        case .vacuum: .operationModeVacuum
        case .mop: .operationModeMop
        case .vacuumAndMop: .operationModeVacuumAndMop
        case .vacuumThenMop: .operationModeVacuumThenMop
        default: nil
        }
    }
}

/// Segmented-control item used to present supported cleaning iteration counts.
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
/// Displays the primary robot controls and keeps them synchronized with live state updates.
class VTRobotControlViewController: VTViewController {
    /// Cleaning configuration to use when the start button is clicked.
    private var supportsSegmentation: Bool = false
    private var supportsZoneCleaning: Bool = false
    private var supportsGoToLocation: Bool = false
    private var segmentIterationRange: ClosedRange<Int> = 1 ... 1
    private var zoneIterationRange: ClosedRange<Int> = 1 ... 1
    private var availableStatistics: Set<VTValetudoDataPointType> = []
    private var _currentConfiguration: VTCleaningConfiguration = .full
    var currentConfiguration: VTCleaningConfiguration {
        get { _currentConfiguration }
        set {
            switch newValue {
            case .full:
                _currentConfiguration = .full
            case .segments:
                _currentConfiguration = supportsSegmentation ? newValue : .full
            case .zones:
                _currentConfiguration = supportsZoneCleaning ? newValue : .full
            case .goTo:
                _currentConfiguration = supportsGoToLocation ? newValue : .full
            }
            updateIterations()
            updateStartPausePresentation()
        }
    }

    var currentIterations: Int {
        currentConfiguration.iterations
    }

    private let client: VTAPIClientProtocol
    private var observerToken: VTListenerToken?
    private var sseTask: Task<Void, Never>?
    private var hasConnectedStateAttributesStream = false
    private var latestStateAttributes: VTStateAttributeList?
    private var lastKnownActiveAction: VTActiveRobotAction?
    var startActionHandler: ((VTCleaningConfiguration) async throws -> Bool)?

    /// Make sure that we process manual UI updates and SSE based UI updates in the right order
    private let serialTaskQueue: SerialTaskQueue = .init()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let startPauseStopControl = VTStartPauseStopControlRow()

    let modeRow = VTSegmentedControlRow<VTOperationModeItem>(
        title: VTPresetType.operationMode.description.capitalized,
        titleIcon: .operationModeControl
    )

    private let fanRow = VTSegmentedControlRow<VTFanItem>(
        title: VTPresetType.fanSpeed.description.capitalized,
        titleIcon: .fanSpeedControl
    )
    private let waterRow = VTSegmentedControlRow<VTWaterGradeItem>(
        title: VTPresetType.waterGrade.description.capitalized,
        titleIcon: .waterGradeControl
    )
    private let iterationsRow = VTSegmentedControlRow<VTRepeatItem>(
        title: "ITERATIONS".localized(),
        titleIcon: .cleaningIterationsControl
    )

    private let dockControls = {
        let dockControls = VTStackedControlRow<VTControlButton>(
            title: "CHARGER".localized(),
            titleIcon: .dockControls
        )
        dockControls.translatesAutoresizingMaskIntoConstraints = false
        dockControls.axis = .horizontal

        let cleanButton = VTToggleControlButton(
            title: "CLEAN".localizedUppercase(),
            icon: .dockMopWash
        )
        let dryButton = VTToggleControlButton(
            title: "DRY".localizedUppercase(),
            icon: .dockMopDry
        )
        let emptyButton = VTControlButton(
            title: "EMPTY".localizedUppercase(),
            icon: .dockEmpty
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
            titleIcon: .attachments
        )
        attachmentsControls.axis = .vertical
        attachmentsControls.translatesAutoresizingMaskIntoConstraints = false
        return attachmentsControls
    }()

    private let statisticsControls = {
        let statisticsControls = VTStackedControlRow<VTControlLabel>(
            title: "CURRENT_STATISTICS".localized(),
            titleIcon: .currentStatistics
        )
        statisticsControls.axis = .horizontal
        statisticsControls.translatesAutoresizingMaskIntoConstraints = false
        return statisticsControls
    }()

    // MARK: - Init

    /// Creates the robot control screen for the provided API client.
    init(client: VTAPIClientProtocol) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    /// Configures the control rows after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        // view.backgroundColor = .systemBackground
        setupControls()
    }

    /// Starts observing robot state updates while the screen is visible.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSSEObservation()
    }

    /// Stops live robot observation when the screen leaves the foreground.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopSSEObservation()
    }

    @MainActor
    /// Reconnects the live state stream and reloads the current control state.
    override func reconnectAndRefresh() async {
        // Cancel existing SSE task and reconnect
        stopSSEObservation()
        startSSEObservation()
    }

    // MARK: - State Observation

    /// Starts the state-attribute event stream and wires incoming updates into the UI.
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
                        // The first connect only confirms the stream is ready. Subsequent reconnects
                        // trigger a full refresh so the UI catches up with anything missed offline.
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
                    /* showRobotControlError(
                         messageKey: "ROBOT_CONTROL_STATE_ATTRIBUTES_FAILED_MESSAGE",
                         reason: msg
                     ) */
                    default:
                        break
                    }
                }
            } catch {
                log(message: "Failed to update data: \(error.localizedDescription)", forSubsystem: .robotControl, level: .error)
                /* showRobotControlError(
                     messageKey: "ROBOT_CONTROL_INITIAL_LOAD_FAILED_MESSAGE",
                     reason: error.localizedDescription
                 ) */
            }
        }
    }

    /// Tears down the active state-attribute stream and unregisters its observer.
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

    // MARK: - Error Presentation

    /// Presents a localized robot-control error with the supplied failure reason.
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
    /// Loads capabilities, presets, statistics, and the initial robot state for the screen.
    func loadInitialData() async throws {
        try await collecting { [weak self] run in
            guard let self else { return }

            await run {
                let capibilities = await Set((try? client.getCapabilities()) ?? [])
                self.supportsSegmentation = capibilities.contains(.mapSegmentation)
                self.supportsZoneCleaning = capibilities.contains(.zoneCleaning)
                self.supportsGoToLocation = capibilities.contains(.goToLocation)
                if !self.supportsSegmentation, !self.supportsZoneCleaning, !self.supportsGoToLocation {
                    self.currentConfiguration = .full
                }

                let mapSegmentationProperties: VTMapSegmentationProperties? = if self.supportsSegmentation {
                    try? await self.client.getMapSegmentationProperties()
                } else {
                    nil
                }
                let zoneCleaningProperties: VTZoneCleaningCapabilityProperties? = if self.supportsZoneCleaning {
                    try? await self.client.getZoneCleaningCapabilityProperties()
                } else {
                    nil
                }
                let currentStatisticsProperties: VTStatisticsCapabilityProperties? = if capibilities.contains(.currentStatistics) {
                    try? await self.client.getCurrentStatisticsCapabilityProperties()
                } else {
                    nil
                }

                self.segmentIterationRange = if let iterationCount = mapSegmentationProperties?.iterationCount {
                    iterationCount.min ... iterationCount.max
                } else {
                    1 ... 1
                }
                self.zoneIterationRange = if let iterationCount = zoneCleaningProperties?.iterationCount {
                    iterationCount.min ... iterationCount.max
                } else {
                    1 ... 1
                }
                self.availableStatistics = Set(currentStatisticsProperties?.availableStatistics ?? [])
                self.updateIterations()

                self.startPauseStopControl.isHidden = !capibilities.contains(.basicControl)
                self.statisticsControls.isHidden = !capibilities.contains(.currentStatistics)
                self.iterationsRow.isHidden = !(capibilities.contains(.mapSegmentation) || capibilities.contains(.zoneCleaning))
                self.emptyButton?.isHidden = !capibilities.contains(.autoEmptyDockManualTrigger)
                self.cleanButton?.isHidden = !capibilities.contains(.mopDockCleanManualTrigger)
                self.dryButton?.isHidden = !capibilities.contains(.mopDockDryManualTrigger)
                // Hide controls that the current robot firmware does not expose.
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

    // MARK: - UI Updates

    @MainActor
    /// Reloads button state from the latest state attributes endpoint.
    private func updateButtons() async {
        await serialTaskQueue.enqueue { [weak self] in
            guard let self else { return }
            if let initialAttrs = try? await client.getStateAttributes() {
                await updateButtonStates(initialAttrs)
            }
        }
    }

    @MainActor
    /// Rebuilds the iterations row for the currently selected cleaning mode.
    private func updateIterations() {
        let config = currentConfiguration
        let iterationRange: ClosedRange<Int> = switch config {
        case .segments:
            segmentIterationRange
        case .zones:
            zoneIterationRange
        case .full, .goTo:
            1 ... 1
        }

        iterationsRow.values = VTRepeatItem.items(in: iterationRange)
        iterationsRow.isEnabled = true // allow changes to `selectedValue`
        iterationsRow.subtitle = "x \(config.iterations)"
        iterationsRow.selectedValue = VTRepeatItem(iterations: config.iterations)
        iterationsRow.isEnabled = config.canChangeIterations
    }

    @MainActor
    /// Fetches the latest statistics payload and applies it to the statistics row.
    private func updateStatistics() async throws {
        let currentStatistics = try await client.getCurrentStatisticsCapability()
        await updateStatistics(currentStatistics)
    }

    @MainActor
    /// Rebuilds the visible statistics controls from the provided datapoints.
    private func updateStatistics(_ statistics: [VTValetudoDataPoint]) async {
        let visibleStatistics = if availableStatistics.isEmpty {
            statistics
        } else {
            statistics.filter { availableStatistics.contains($0.type) }
        }

        statisticsControls.items = visibleStatistics.map { dataPoint in
            let label = VTControlLabel(
                title: dataPoint.type.description.capitalized,
                subtitle: dataPoint.description
            )
            label.heightAnchor.constraint(equalToConstant: 50).isActive = true
            return label
        }
    }

    @MainActor
    /// Applies state-dependent enablement and selected preset values to all visible controls.
    private func updateButtonStates(_ state: VTStateAttributeList) async {
        latestStateAttributes = state
        startPauseStopControl.isStopEnabled = state.isStoppable
        startPauseStopControl.isHomeEnabled = state.canReturnHome
        updateStartPausePresentation(with: state)

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
    /// Refreshes the start/pause control using the last cached state attributes.
    private func updateStartPausePresentation() {
        guard let latestStateAttributes else { return }
        updateStartPausePresentation(with: latestStateAttributes)
    }

    @MainActor
    /// Derives the correct start or pause presentation from the current robot state.
    private func updateStartPausePresentation(with state: VTStateAttributeList) {
        let activeAction = resolvedActiveAction(from: state)

        if let activeAction {
            lastKnownActiveAction = activeAction
        } else if !state.isStarted, !state.isResumable {
            lastKnownActiveAction = nil
        }

        let canPauseCurrentAction = state.isStarted && (activeAction == .mapping || activeAction?.controlMode == currentConfiguration.controlMode)
        let startBadge = state.isResumable ? activeAction?.badgeImage : currentConfiguration.badgeImage
        startPauseStopControl.startPausePresentation = canPauseCurrentAction
            ? .pause
            : .start(badge: startBadge)

        if state.isStarted || state.isPaused {
            startPauseStopControl.isStartPauseEnabled = true
        } else {
            // A robot can be busy without exposing a resumable start/pause action, for example
            // while manual control is active.
            startPauseStopControl.isStartPauseEnabled = false
        }
    }

    /// Resolves the currently active logical action from the robot's raw state flags.
    private func resolvedActiveAction(from state: VTStateAttributeList) -> VTActiveRobotAction? {
        switch state.statusFlag {
        case .segment:
            .segment
        case .zone, .spot: // not sure what to do with spot...
            .zone
        case .target:
            .goTo
        case .mapping:
            .mapping
        case .resumable:
            lastKnownActiveAction
        case .some(.none), nil:
            state.isStarted ? .segment : nil
        }
    }

    @MainActor
    /// Rebuilds the attachment row from the currently attached hardware accessories.
    private func updateAttachments(_ state: VTStateAttributeList) async {
        // Attachment rows are informational only, so they are recreated from scratch on each update.
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

    // MARK: - Robot Actions

    /// Starts, resumes, or pauses the active cleaning flow depending on the current robot state.
    private func toggleStartPause(isStarted: Bool) async {
        do {
            if isStarted {
                try await client.pause()
            } else {
                if latestStateAttributes?.isResumable == true {
                    try await client.start()
                    return
                }
                if try await startActionHandler?(currentConfiguration) == true {
                    return
                }
                // Fall back to the default API action when no higher-level handler intercepts the request.
                switch currentConfiguration {
                case .full:
                    try await client.start()
                case let .segments(ids: ids, customOrder: order, iterations: iters):
                    try await client.clean(segmentIDs: ids, customOrder: order, iterations: iters)
                case let .zones(zones, iterations: iters):
                    try await client.clean(zones: zones, iterations: iters)
                case let .goTo(coordinate):
                    try await client.goTo(x: coordinate.x, y: coordinate.y)
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

    /// Stops the current robot activity.
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

    /// Sends the robot back to its dock.
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

    /// Applies a newly selected fan speed preset.
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

    /// Applies a newly selected water grade preset.
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

    /// Applies a newly selected operation mode preset.
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
    /// Toggles mop-pad drying on the dock.
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
    /// Toggles mop-pad cleaning on the dock.
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
    /// Triggers a manual auto-empty cycle on the dock.
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

    // MARK: - Setup

    /// Wires callbacks, lays out the control rows, and assembles the scroll view hierarchy.
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

        // Keep the content stack pinned to the scroll view's frame width so rows size like a
        // vertically scrolling form instead of expanding to their intrinsic content width.
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
