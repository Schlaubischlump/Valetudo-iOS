//
//  VTMockAPIClient.swift
//  Valetudo
//
//  Created by David Klopp on 21.04.26.
//
import CoreGraphics
import CoreImage
import Foundation

extension VTStateAttributeList {
    init(attributes: [any VTStateAttribute]) {
        self.attributes = attributes
    }
}

actor VTMockAPIClient: VTAPIClientProtocol {
    static let shared: VTMockAPIClient? = VTMockAPIClient()

    private static let defaultPresetSelections: [VTPresetType: VTPresetValue] = [
        .fanSpeed: .medium,
        .waterGrade: .low,
        .operationMode: .vacuumAndMop,
    ]

    private var timers: [String: VTTimer]
    private var events: [any VTValetudoEvent]
    private var stateAttributes = VTMockAPIClient.makeStateAttributes(presetSelections: VTMockAPIClient.defaultPresetSelections)
    private var logLevel = "info"
    private var updaterConfig = VTUpdaterConfig(updateProvider: .github)
    private var manualControlEnabled = false
    private var highResolutionManualControlEnabled = false
    private var obstacleImagesEnabled = true
    private var presetSelections = VTMockAPIClient.defaultPresetSelections
    private var observerTasks: [VTListenerToken: Task<Void, Never>] = [:]
    private var nextEventNumber = 1

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
        timers = [timer.id!: timer]
        events = []
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
        stateAttributes
    }

    func getMap() async throws -> VTMapData {
        mockMap()
    }

    @discardableResult
    func registerEventObserver<O>(for endpoint: VTEventEndpoint<some Decodable & Equatable, O>) async -> (VTListenerToken, AsyncStream<VTEventAction<O>>) {
        let token = UUID()
        let stream = AsyncStream<VTEventAction<O>> { continuation in
            continuation.yield(.didConnect)

            let task = Task { [weak self] in
                guard let self else { return }
                await emitEvent(for: endpoint, to: continuation)
                var lastStateAttributes = await stateAttributesIfNeeded(for: endpoint)

                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    guard !Task.isCancelled else { break }

                    switch endpoint.eventID {
                    case .stateAttributes:
                        let currentStateAttributes = await currentStateAttributes()
                        guard currentStateAttributes != lastStateAttributes else { continue }
                        lastStateAttributes = currentStateAttributes
                        await emitEvent(for: endpoint, to: continuation)
                    case .valetudoEvent:
                        guard await addRandomDummyEvent() else { continue }
                        await emitEvent(for: endpoint, to: continuation)
                    case .map:
                        continue
                    }
                }
            }

            observerTasks[token] = task
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeEventObserver(token: token, for: endpoint) }
            }
        }

        return (token, stream)
    }

    func removeEventObserver(token: VTListenerToken, for _: VTEventEndpoint<some Decodable & Equatable, some Any>) async {
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
            .mopDockDryManualTrigger,
        ]
    }

    func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        [
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .time, value: 12345),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .area, value: 543_210),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .count, value: 42),
        ]
    }

    func start() async throws {}
    func pause() async throws {}
    func stop() async throws {}
    func home() async throws {}
    func clean(segmentIDs _: [String], customOrder _: Bool, iterations _: Int) async throws {}
    func autoEmptyDock() async throws {}
    func startMopDockClean() async throws {}
    func stopMopDockClean() async throws {}
    func startMopDockDry() async throws {}
    func stopMopDockDry() async throws {}

    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue] {
        switch type {
        case .fanSpeed:
            [.low, .medium, .high, .max]
        case .waterGrade:
            [.low, .medium, .high]
        case .operationMode:
            [.vacuum, .mop, .vacuumAndMop, .vacuumThenMop]
        }
    }

    func setPreset(_ preset: VTPresetValue, forType type: VTPresetType) async throws {
        presetSelections[type] = preset
        stateAttributes = Self.makeStateAttributes(presetSelections: presetSelections)
    }

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
            ),
        ]
    }

    func getPropertiesForConsumables() async throws -> [VTConsumableStateAttributeProperties] {
        [
            VTConsumableStateAttributeProperties(type: .brush, subType: .main, unit: .percent, maxValue: 100),
            VTConsumableStateAttributeProperties(type: .filter, subType: .main, unit: .minutes, maxValue: 900),
        ]
    }

    func resetConsumable(type _: VTConsumableType) async throws {}
    func resetConsumable(type _: VTConsumableType, subtype _: VTConsumableSubType) async throws {}

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

    func manualControlMove(direction _: VTMoveDirection) async throws {}

    func getHighResolutionManualControlIsEnabled() async throws -> Bool {
        highResolutionManualControlEnabled
    }

    func enableHighResolutionManualControl() async throws {
        highResolutionManualControlEnabled = true
    }

    func disableHighResolutionManualControl() async throws {
        highResolutionManualControlEnabled = false
    }

    func highResolutionManualControlMove(angle _: CGFloat, velocity _: CGFloat) async throws {}

    // MARK: - 1.2.11 ObstacleImagesCapability

    func getObstacleImagesCapabilityIsEnabled() async throws -> Bool {
        obstacleImagesEnabled
    }

    func enableObstacleImagesCapability() async throws {
        obstacleImagesEnabled = true
    }

    func disableObstacleImagesCapability() async throws {
        obstacleImagesEnabled = false
    }

    func getObstacleImage(id: String) async throws -> CIImage {
        let tint: CIColor = switch id {
        case "fc9a6d96-359c-53b5-93eb-d98918efcb57": .init(red: 0.30, green: 0.60, blue: 0.95)
        case "7d50387c-244d-53c4-8bff-179868c82bec": .init(red: 0.96, green: 0.61, blue: 0.20)
        default: .init(red: 0.55, green: 0.55, blue: 0.55)
        }

        return CIImage(color: tint).cropped(to: CGRect(x: 0, y: 0, width: 220, height: 220))
    }

    func getObstacleImagesCapabilityProperties() async throws -> VTObstacleImagesProperties {
        VTObstacleImagesProperties(fileFormat: .ok, dimensions: .init(width: 0, height: 0))
    }

    // MARK: - 1.2.12 MapResetCapability

    func resetMap() async throws {}

    func getMapResetProperties() async throws -> [String: VTAnyCodable] {
        [:]
    }

    // MARK: - 1.2.13 MappingPassCapability

    func startMappingPass() async throws {}

    func getMappingPassProperties() async throws -> [String: VTAnyCodable] {
        [:]
    }

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
            uptime: 12345,
            load: VTLoad(one: 0.1, five: 0.2, fifteen: 0.3),
            cpus: [VTCPU(usage: VTUsage(user: 5, nice: 0, sys: 3, idle: 91, irq: 1))]
        )
    }

    func getRuntimeInfo() async throws -> VTRuntimeInfo {
        VTRuntimeInfo(
            uptime: 4321,
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

    func canReachValetudo() async -> Bool {
        true
    }

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
            VTLogLine(timestamp: Date(), level: "debug", message: "Mock log entry"),
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
        timers
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

    func executeTimer(id _: String) async throws {}

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
        guard let event = events.first(where: { $0.id == id }) else { throw VTAPIError.missingID(String(describing: (any VTValetudoEvent).self)) }
        return event
    }

    func interactWithValetudoEvent(id: String, interaction _: VTEventInteraction) async throws {
        events.removeAll { $0.id == id }
    }

    // MARK: - 7. NetworkAdvertisement

    func getNetworkAdvertisementProperties() async throws -> VTNetworkAdvertisementProperties {
        VTNetworkAdvertisementProperties(port: 80, zeroconfHostname: "127.0.0.0")
    }

    // MARK: - Helpers

    private func storeObserverTask(_ task: Task<Void, Never>, for token: VTListenerToken) {
        observerTasks[token] = task
    }

    private func emitEvent<O>(for endpoint: VTEventEndpoint<some Decodable & Equatable, O>, to continuation: AsyncStream<VTEventAction<O>>.Continuation) {
        switch endpoint.eventID {
        case .stateAttributes:
            yield(stateAttributes, to: continuation)
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

    private func currentStateAttributes() -> VTStateAttributeList {
        stateAttributes
    }

    private func stateAttributesIfNeeded(for endpoint: VTEventEndpoint<some Decodable & Equatable, some Any>) -> VTStateAttributeList? {
        endpoint.eventID == .stateAttributes ? stateAttributes : nil
    }

    private func addRandomDummyEvent() -> Bool {
        guard Int.random(in: 1 ... 100) <= 20 else { return false }

        let id = "mock-event-\(nextEventNumber)"
        nextEventNumber += 1
        let timestamp = Date()

        let event: any VTValetudoEvent = switch Int.random(in: 0 ..< 6) {
        case 0:
            VTDustBinFullEvent(
                __class: "DustBinFullValetudoEvent",
                metaData: [:],
                id: id,
                timestamp: timestamp,
                processed: false
            )
        case 1:
            VTConsumableDepletedEvent(
                __class: "ConsumableDepletedValetudoEvent",
                metaData: [:],
                id: id,
                timestamp: timestamp,
                processed: false,
                type: .brush,
                subType: .main
            )
        case 2:
            VTErrorStateEvent(
                __class: "ErrorStateValetudoEvent",
                metaData: [:],
                id: id,
                timestamp: timestamp,
                processed: false,
                message: "Mock robot reported a temporary navigation issue."
            )
        case 3:
            VTMissingResourceEvent(
                __class: "MissingResourceValetudoEvent",
                metaData: [:],
                id: id,
                timestamp: timestamp,
                processed: false,
                message: "Mock map resource is temporarily unavailable."
            )
        case 4:
            VTMopAttachmentReminderEvent(
                __class: "MopAttachmentReminderValetudoEvent",
                metaData: [:],
                id: id,
                timestamp: timestamp,
                processed: false
            )
        default:
            VTPendingMapChangeEvent(
                __class: "PendingMapChangeValetudoEvent",
                metaData: [:],
                id: id,
                timestamp: timestamp,
                processed: false
            )
        }

        events.append(event)
        return true
    }

    private static func makeStateAttributes(presetSelections: [VTPresetType: VTPresetValue]) -> VTStateAttributeList {
        VTStateAttributeList(attributes: [
            VTStatusStateAttribute(__class: "StatusStateAttribute", metaData: [:], value: .docked, flag: VTStatusFlag.none),
            VTBatteryStateAttribute(__class: "BatteryStateAttribute", metaData: [:], level: 88, flag: .charged),
            VTDockStatusStateAttribute(__class: "DockStatusStateAttribute", metaData: [:], value: .idle),
            VTAttachmentStateAttribute(__class: "AttachmentStateAttribute", metaData: [:], type: .dustbin, attached: true),
            VTAttachmentStateAttribute(__class: "AttachmentStateAttribute", metaData: [:], type: .mop, attached: true),
            VTPresetSelectionStateAttribute(__class: "PresetSelectionStateAttribute", metaData: [:], type: .fanSpeed, value: presetSelections[.fanSpeed] ?? .medium, customValue: nil),
            VTPresetSelectionStateAttribute(__class: "PresetSelectionStateAttribute", metaData: [:], type: .waterGrade, value: presetSelections[.waterGrade] ?? .low, customValue: nil),
            VTPresetSelectionStateAttribute(__class: "PresetSelectionStateAttribute", metaData: [:], type: .operationMode, value: presetSelections[.operationMode] ?? .vacuumAndMop, customValue: nil),
        ])
    }

    private func mockMap() -> VTMapData {
        do {
            return try JSONDecoder().decode(VTMapData.self, from: Data(VTMockMapData.mapJSON.utf8))
        } catch {
            log(message: "Failed to decode mock map data: \(error.localizedDescription)", forSubsystem: .mock, level: .error)
            return VTMapData(size: VTSize(x: 0, y: 0), pixelSize: 1, layers: [], entities: [], metaData: VTMetaData(version: 2))
        }
    }
}
