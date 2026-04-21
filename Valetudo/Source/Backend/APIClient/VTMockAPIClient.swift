//
//  VTMockAPIClient.swift
//  Valetudo
//
//  Created by David Klopp on 21.04.26.
//
import CoreGraphics
import Foundation

actor VTMockAPIClient: VTAPIClientProtocol {
    static let shared: VTMockAPIClient? = VTMockAPIClient()

    private var timers: [String: VTTimer]
    private var events: [any VTValetudoEvent]
    private var logLevel = "info"
    private var updaterConfig = VTUpdaterConfig(updateProvider: .github)
    private var manualControlEnabled = false
    private var highResolutionManualControlEnabled = false
    private var getTimersCallCount = 0
    private var observerTasks: [VTListenerToken: Task<Void, Never>] = [:]

    init() {
        let timer = VTTimer(
            id: "mock-morning-clean",
            enabled: true,
            label: "Morning clean",
            dow: [1, 2, 3, 4, 5],
            hour: 9,
            minute: 13,
            action: .fullCleanup,
            preActions: [],
            metaData: nil
        )
        self.timers = [timer.id!: timer]
        self.events = []
    }

    // MARK: - 1. Robot

    func getRobotInfo() async throws -> VTRobotInfo {
        VTRobotInfo(
            manufacturer: "Mock",
            modelName: "Valetudo Robot",
            modelDetails: VTModelDetails(supportedAttachments: [.dustbin, .watertank, .mop]),
            implementation: "mock"
        )
    }

    // MARK: - 1.1 State

    func getStateAttributes() async throws -> VTStateAttributeList {
        mockStateAttributes()
    }

    func getMap() async throws -> VTMapData {
        VTMapData(
            size: VTSize(x: 20, y: 20),
            pixelSize: 50,
            layers: [
                VTLayer(
                    __class: "MapLayer",
                    metaData: [
                        "segmentId": .string("1"),
                        "name": .string("Living Room"),
                        "active": .bool(true),
                        "area": .int(200000)
                    ],
                    type: .segment,
                    pixels: [0, 0, 20, 20],
                    compressedPixels: nil,
                    dimensions: VTDimensions(
                        x: VTRangeDimension(min: 0, max: 20, mid: 10, avg: nil),
                        y: VTRangeDimension(min: 0, max: 20, mid: 10, avg: nil),
                        pixelCount: 400
                    )
                )
            ],
            entities: [
                VTEntity(
                    __class: "MapEntity",
                    metaData: [:],
                    type: .charger_location,
                    points: [2, 2]
                ),
                VTEntity(
                    __class: "MapEntity",
                    metaData: [:],
                    type: .robot_position,
                    points: [10, 10, 0]
                )
            ],
            metaData: VTMetaData(version: 1)
        )
    }

    @discardableResult
    func registerEventObserver<E: Decodable & Equatable, O>(for endpoint: VTEventEndpoint<E, O>) async -> (VTListenerToken, AsyncStream<VTEventAction<O>>) {
        let token = UUID()
        let stream = AsyncStream<VTEventAction<O>> { continuation in
            continuation.yield(.didConnect)

            let task = Task { [weak self] in
                guard let self else { return }
                await self.emitEvent(for: endpoint, to: continuation)

                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    guard !Task.isCancelled else { break }
                    await self.tick(endpoint: endpoint)
                    await self.emitEvent(for: endpoint, to: continuation)
                }
            }

            Task { await self.storeObserverTask(task, for: token) }
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeEventObserver(token: token, for: endpoint) }
            }
        }

        return (token, stream)
    }

    func removeEventObserver<E: Decodable & Equatable, O>(token: VTListenerToken, for endpoint: VTEventEndpoint<E, O>) async {
        observerTasks[token]?.cancel()
        observerTasks[token] = nil
    }

    // MARK: - 1.2 Capabilities

    func getCapabilities() async throws -> [VTCapability] {
        [
            .basicControl,
            .currentStatistics,
            .mapSegmentation,
            .fanSpeedControl,
            .waterUsageControl,
            .operationModeControl,
            .consumableMonitoring,
            .manualControl,
            .highResolutionManualControl,
            .autoEmptyDockManualTrigger,
            .mopDockCleanManualTrigger,
            .mopDockDryManualTrigger
        ]
    }

    func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        [
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .time, value: 12_345),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .area, value: 543_210),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .count, value: 42)
        ]
    }

    func start() async throws {}
    func pause() async throws {}
    func stop() async throws {}
    func home() async throws {}
    func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws {}
    func autoEmptyDock() async throws {}
    func startMopDockClean() async throws {}
    func stopMopDockClean() async throws {}
    func startMopDockDry() async throws {}
    func stopMopDockDry() async throws {}

    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue] {
        switch type {
        case .fanSpeed:
            [.off, .min, .low, .medium, .high, .max, .turbo]
        case .waterGrade:
            [.off, .low, .medium, .high, .max]
        case .operationMode:
            [.vacuum, .mop, .vacuumAndMop, .vacuumThenMop]
        }
    }

    func setPreset(_ preset: VTPresetValue, forType type: VTPresetType) async throws {}

    func getConsumables() async throws -> [VTConsumableStateAttribute] {
        [
            VTConsumableStateAttribute(
                __class: "ValetudoConsumable",
                metaData: [:],
                type: .brush,
                subType: .main,
                remaining: VTConsumableRemaining(value: 78, unit: .percent)
            ),
            VTConsumableStateAttribute(
                __class: "ValetudoConsumable",
                metaData: [:],
                type: .filter,
                subType: .main,
                remaining: VTConsumableRemaining(value: 420, unit: .minutes)
            )
        ]
    }

    func getPropertiesForConsumables() async throws -> [VTConsumableStateAttributeProperties] {
        [
            VTConsumableStateAttributeProperties(type: .brush, subType: .main, unit: .percent, maxValue: 100),
            VTConsumableStateAttributeProperties(type: .filter, subType: .main, unit: .minutes, maxValue: 900)
        ]
    }

    func resetConsumable(type: VTConsumableType) async throws {}
    func resetConsumable(type: VTConsumableType, subtype: VTConsumableSubType) async throws {}

    func getManualControlIsEnabled() async throws -> Bool {
        manualControlEnabled
    }

    func getManualControlSupportedMovementDirections() async throws -> [VTMoveDirection] {
        [.forward, .backward, .rotateClockwise, .rotateCounterclockwise]
    }

    func enableManualControl() async throws {
        manualControlEnabled = true
    }

    func disableManualControl() async throws {
        manualControlEnabled = false
    }

    func manualControlMove(direction: VTMoveDirection) async throws {}

    func getHighResolutionManualControlIsEnabled() async throws -> Bool {
        highResolutionManualControlEnabled
    }

    func enableHighResolutionManualControl() async throws {
        highResolutionManualControlEnabled = true
    }

    func disableHighResolutionManualControl() async throws {
        highResolutionManualControlEnabled = false
    }

    func highResolutionManualControlMove(angle: CGFloat, velocity: CGFloat) async throws {}

    // MARK: - 1.3 Properties

    func getRobotProperties() async throws -> VTRobotProperties {
        ["firmwareVersion": "mock-1.0"]
    }

    // MARK: - 2. System

    func getHostInfo() async throws -> VTHostInfo {
        VTHostInfo(
            hostname: "mock-valetudo",
            arch: "arm64",
            mem: VTMemory(total: 512, free: 256, valetudo_current: 64, valetudo_max: 128),
            uptime: 12_345,
            load: VTLoad(one: 0.1, five: 0.2, fifteen: 0.3),
            cpus: [VTCPU(usage: VTUsage(user: 5, nice: 0, sys: 3, idle: 91, irq: 1))]
        )
    }

    func getRuntimeInfo() async throws -> VTRuntimeInfo {
        VTRuntimeInfo(
            uptime: 4_321,
            argv: ["valetudo"],
            execArgv: [],
            execPath: "/usr/bin/valetudo",
            uid: 1000,
            gid: 1000,
            pid: 123,
            versions: ["node": "mock"],
            env: ["MODE": "mock"]
        )
    }

    // MARK: - 3. Valetudo

    func getBasicValetudoInfo() async throws -> VTBasicValetudoInfo {
        VTBasicValetudoInfo(embedded: true, systemId: "mock-system", welcomeDialogDismissed: true)
    }

    func getValetudoVersionInfo() async throws -> VTValetudoVersionInfo {
        VTValetudoVersionInfo(release: "mock", commit: "0000000")
    }

    func getLogProperties() async throws -> VTLogLevel {
        VTLogLevel(current: logLevel, presets: ["trace", "debug", "info", "warn", "error"])
    }

    func setLogLevel(_ level: String) async throws {
        logLevel = level
    }

    func getLog() async throws -> [VTLogLine] {
        [
            VTLogLine(timestamp: Date(), level: "info", message: "Mock client started"),
            VTLogLine(timestamp: Date(), level: "debug", message: "Mock log entry")
        ]
    }

    // MARK: - 4. Updater

    func checkForUpdate() async throws {}
    func downloadUpdate() async throws {}
    func applyUpdate() async throws {}

    func getUpdaterState() async throws -> any VTUpdaterState {
        VTUpdaterIdleState(
            className: "ValetudoUpdaterIdleState",
            timestamp: Date(),
            busy: false,
            metaData: [:],
            currentVersion: "mock"
        )
    }

    func getUpdaterConfiguration() async throws -> VTUpdaterConfig {
        updaterConfig
    }

    func setUpdaterConfiguration(_ config: VTUpdaterConfig) async throws {
        updaterConfig = config
    }

    // MARK: - 5. Timer

    func getTimers() async throws -> [String: VTTimer] {
        getTimersCallCount += 1
        if getTimersCallCount.isMultiple(of: 5) {
            addDummyEvent()
        }
        return timers
    }

    func addTimer(_ timer: VTTimer) async throws {
        let id = timer.id ?? "mock-timer-\(timers.count + 1)"
        timers[id] = VTTimer(
            id: id,
            enabled: timer.enabled,
            label: timer.label,
            dow: timer.dow,
            hour: timer.hour,
            minute: timer.minute,
            action: timer.action,
            preActions: timer.preActions,
            metaData: timer.metaData
        )
    }

    func getTimer(id: String) async throws -> VTTimer {
        guard let timer = timers[id] else { throw VTAPIError.missingID(String(describing: VTTimer.self)) }
        return timer
    }

    func updateTimer(_ timer: VTTimer) async throws {
        guard let id = timer.id else { throw VTAPIError.missingID(String(describing: VTTimer.self)) }
        timers[id] = timer
    }

    func deleteTimer(id: String) async throws {
        timers[id] = nil
    }

    func executeTimer(id: String) async throws {}

    func getTimerProperties() async throws -> VTTimersProperties {
        VTTimersProperties(
            supportedActions: [.fullCleanup, .segmentCleanup],
            supportedPreActions: [.fanSpeedControl, .waterUsageControl, .operationModeControl]
        )
    }

    // MARK: - 6. Events

    func getValetudoEvents() async throws -> [any VTValetudoEvent] {
        events
    }

    func getValetudoEvent(id: String) async throws -> any VTValetudoEvent {
        guard let event = events.first(where: { $0.id == id }) else { throw VTAPIError.missingID(String(describing: VTValetudoEvent.self)) }
        return event
    }

    func interactWithValetudoEvent(id: String, interaction: VTEventInteraction) async throws {
        events.removeAll { $0.id == id }
    }

    // MARK: - Helpers

    private func storeObserverTask(_ task: Task<Void, Never>, for token: VTListenerToken) {
        observerTasks[token] = task
    }

    private func tick<E: Decodable & Equatable, O>(endpoint: VTEventEndpoint<E, O>) {
        if endpoint.eventID == .valetudoEvent {
            addDummyEvent()
        }
    }

    private func emitEvent<E: Decodable & Equatable, O>(for endpoint: VTEventEndpoint<E, O>, to continuation: AsyncStream<VTEventAction<O>>.Continuation) {
        switch endpoint.eventID {
        case .stateAttributes:
            yield(mockStateAttributes(), to: continuation)
        case .map:
            yield(mockMap(), to: continuation)
        case .valetudoEvent:
            yield(events, to: continuation)
        }
    }

    private func yield<O>(_ value: Any, to continuation: AsyncStream<VTEventAction<O>>.Continuation) {
        guard let output = value as? O else {
            continuation.yield(.didReceiveError("Mock endpoint output type mismatch."))
            return
        }
        continuation.yield(.didReceiveData(output))
    }

    private func addDummyEvent() {
        events.append(
            VTDustBinFullEvent(
                __class: "DustBinFullValetudoEvent",
                metaData: [:],
                id: "mock-event-\(events.count + 1)",
                timestamp: Date(),
                processed: false
            )
        )
    }

    private func mockStateAttributes() -> VTStateAttributeList {
        VTStateAttributeList(attributes: [
            VTStatusStateAttribute(__class: "StatusStateAttribute", metaData: [:], value: .docked, flag: .none),
            VTBatteryStateAttribute(__class: "BatteryStateAttribute", metaData: [:], level: 88, flag: .charged),
            VTDockStatusStateAttribute(__class: "DockStatusStateAttribute", metaData: [:], value: .idle),
            VTAttachmentStateAttribute(__class: "AttachmentStateAttribute", metaData: [:], type: .dustbin, attached: true),
            VTAttachmentStateAttribute(__class: "AttachmentStateAttribute", metaData: [:], type: .mop, attached: true),
            VTPresetSelectionStateAttribute(__class: "PresetSelectionStateAttribute", metaData: [:], type: .fanSpeed, value: .medium, customValue: nil),
            VTPresetSelectionStateAttribute(__class: "PresetSelectionStateAttribute", metaData: [:], type: .waterGrade, value: .low, customValue: nil),
            VTPresetSelectionStateAttribute(__class: "PresetSelectionStateAttribute", metaData: [:], type: .operationMode, value: .vacuumAndMop, customValue: nil)
        ])
    }

    private func mockMap() -> VTMapData {
        VTMapData(
            size: VTSize(x: 20, y: 20),
            pixelSize: 50,
            layers: [],
            entities: [],
            metaData: VTMetaData(version: 1)
        )
    }
}
