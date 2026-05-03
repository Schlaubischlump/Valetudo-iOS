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
    private let emptyMapSegmentEditProperties: VTMapSegmentEditProperties = [:]
    private let emptyMapSegmentRenameProperties: VTMapSegmentRenameProperties = [:]
    private let emptyProperties: [String: VTAnyCodable] = [:]

    func getSupportedMapSegmentMaterials() async throws -> [VTMaterial] {
        [
            .generic,
            .tile,
            .wood,
            .woodVertical,
            .woodVertical,
        ]
    }

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
    private var keyLockEnabled = false
    private var obstacleImagesEnabled = true
    private var toggleCapabilityStates: [String: Bool] = [
        "CarpetModeControlCapability": true,
        "PersistentMapControlCapability": true,
        "ObstacleAvoidanceControlCapability": true,
        "PetObstacleAvoidanceControlCapability": true,
        "CollisionAvoidantNavigationControlCapability": false,
        "MopExtensionControlCapability": true,
        "CameraLightControlCapability": true,
        "MopTwistControlCapability": false,
        "MopExtensionFurnitureLegHandlingControlCapability": true,
        "MopDockMopAutoDryingControlCapability": true,
        "FloorMaterialDirectionAwareNavigationControlCapability": false,
        "PendingMapChangeHandlingCapability": false,
    ]
    private var autoEmptyDockAutoEmptyDuration: VTAutoEmptyDockAutoEmptyDuration = .auto
    private var autoEmptyDockAutoEmptyInterval: VTAutoEmptyDockAutoEmptyInterval = .normal
    private var carpetSensorMode: VTCarpetSensorMode = .avoid
    private var cleanRoute: VTCleanRoute = .normal
    private var doNotDisturbConfiguration = VTDoNotDisturbConfiguration(
        enabled: true,
        start: VTDoNotDisturbTime(hour: 22, minute: 0),
        end: VTDoNotDisturbTime(hour: 8, minute: 0),
        metaData: [:]
    )
    private var mopDockMopDryingDuration: VTMopDockMopDryingDuration = .threeHours
    private var mopDockMopWashTemperature: VTMopDockMopWashTemperature = .warm
    private var quirks = [
        "mock.cleaning.behavior": VTQuirk(
            id: "mock.cleaning.behavior",
            options: ["balanced", "quiet", "aggressive"],
            title: "Cleaning Behavior",
            description: "Mock quirk exposed by the demo client.",
            value: "balanced"
        ),
    ]
    private var speakerVolume = 60
    private var voicePackManagementStatus = VTVoicePackManagementStatus(
        currentLanguage: "en",
        operationStatus: VTVoicePackOperationStatus(type: .idle, progress: nil, metaData: [:])
    )
    private var wifiConfiguration = VTWifiConfiguration(
        state: .connected,
        details: VTWifiDetails(
            ssid: "Valetudo Mock",
            bssid: "00:11:22:33:44:55",
            downspeed: 144,
            upspeed: 54,
            signal: -54,
            ips: ["192.168.1.23"],
            frequency: .twoPointFourGHz
        ),
        metaData: [:]
    )
    private let wifiNetworks: [VTWifiScanResult] = [
        VTWifiScanResult(
            bssid: "00:11:22:33:44:55",
            details: VTWifiScanDetails(ssid: "Valetudo Mock", signal: -54),
            metaData: [:]
        ),
        VTWifiScanResult(
            bssid: "66:77:88:99:AA:BB",
            details: VTWifiScanDetails(ssid: "Guest Network", signal: -71),
            metaData: [:]
        ),
    ]
    private var mapSnapshots: [VTMapSnapshot]
    private var presetSelections = VTMockAPIClient.defaultPresetSelections
    private var mapData = VTMockAPIClient.makeMockMap()
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
        mapSnapshots = [
            VTMapSnapshot(id: "mock-snapshot-1", timestamp: Date().addingTimeInterval(-3600), map: mapData, metaData: [:]),
        ]
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
        mapData
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
                    case .log:
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
            .mapSegmentEdit,
            .mapSegmentRename,
            .mapSegmentMaterialControl,
            .combinedVirtualRestrictions,
            .fanSpeedControl,
            .waterUsageControl,
            .operationModeControl,
            .consumableMonitoring,
            .manualControl,
            .highResolutionManualControl,
            .autoEmptyDockManualTrigger,
            .mopDockCleanManualTrigger,
            .mopDockDryManualTrigger,
            .locate,
            .keyLock,
            .collisionAvoidantNavigationControl,
            .floorMaterialDirectionAwareNavigationControl,
            .cleanRouteControl,
            .carpetModeControl,
            .carpetSensorModeControl,
            .mopTwistControl,
            .obstacleAvoidanceControl,
            .petObstacleAvoidanceControl,
            .obstacleImages,
            .autoEmptyDockAutoEmptyIntervalControl,
            .mopDockMopAutoDryingControl,
            .mopDockMopDryingTimeControl,
            .quirks,
            .voicePackManagement,
            .doNotDisturb,
            .speakerVolumeControl,
            .speakerTest,
        ]
    }

    func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        [
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .time, value: 12345),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .area, value: 543_210),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .count, value: 42),
        ]
    }

    func getCurrentStatisticsCapabilityProperties() async throws -> VTStatisticsCapabilityProperties {
        VTStatisticsCapabilityProperties(availableStatistics: [.count, .time, .area])
    }

    func start() async throws {}
    func pause() async throws {}
    func stop() async throws {}
    func home() async throws {}

    func getBasicControlCapabilityProperties() async throws -> VTBasicControlCapabilityProperties {
        emptyProperties
    }

    func clean(segmentIDs _: [String], customOrder _: Bool, iterations _: Int) async throws {}
    func getMapSegmentationProperties() async throws -> VTMapSegmentationProperties {
        VTMapSegmentationProperties(
            iterationCount: VTMapSegmentationIterationCount(min: 1, max: 3),
            customOrderSupport: true
        )
    }

    func getMapSegments() async throws -> [VTMapSegment] {
        mapData.segmentLayer.compactMap { layer in
            guard let id = layer.segmentId else { return nil }

            return VTMapSegment(
                __class: "ValetudoMapSegment",
                metaData: [:],
                id: id,
                name: layer.name ?? id,
                material: layer.material
            )
        }
    }

    func joinMapSegments(segmentAID _: String, segmentBID _: String) async throws {}
    func splitMapSegment(segmentID _: String, pointA _: CGPoint, pointB _: CGPoint) async throws {}
    func getMapSegmentEditProperties() async throws -> VTMapSegmentEditProperties {
        emptyMapSegmentEditProperties
    }

    func renameMapSegment(segmentID: String, name: String) async throws {
        mapData = VTMapData(
            size: mapData.size,
            pixelSize: mapData.pixelSize,
            layers: mapData.layers.map { layer in
                guard layer.segmentId == segmentID else { return layer }
                var metaData = layer.metaData
                metaData["name"] = .string(name)
                return VTLayer(
                    __class: layer.__class,
                    metaData: metaData,
                    type: layer.type,
                    pixels: layer.pixels,
                    compressedPixels: layer.compressedPixels,
                    dimensions: layer.dimensions
                )
            },
            entities: mapData.entities,
            metaData: mapData.metaData
        )
    }

    func getMapSegmentRenameProperties() async throws -> VTMapSegmentRenameProperties {
        emptyMapSegmentRenameProperties
    }

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

    func getConsumables() async throws -> [VTConsumableState] {
        [
            VTConsumableState(
                __class: "ValetudoConsumable",
                metaData: [:],
                type: .brush,
                subType: .main,
                remaining: VTConsumableRemaining(value: 78, unit: .percent)
            ),
            VTConsumableState(
                __class: "ValetudoConsumable",
                metaData: [:],
                type: .filter,
                subType: .main,
                remaining: VTConsumableRemaining(value: 420, unit: .minutes)
            ),
        ]
    }

    func getPropertiesForConsumables() async throws -> [VTConsumableStateProperties] {
        [
            VTConsumableStateProperties(type: .brush, subType: .main, unit: .percent, maxValue: 100),
            VTConsumableStateProperties(type: .filter, subType: .main, unit: .minutes, maxValue: 900),
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

    func getHighResolutionManualControlCapabilityProperties() async throws -> VTHighResolutionManualControlCapabilityProperties {
        emptyProperties
    }

    // MARK: - 1.2.13 ObstacleImagesCapability

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

    // MARK: - 1.2.14 MapResetCapability

    func resetMap() async throws {}

    func getMapResetProperties() async throws -> VTMapResetProperties {
        [:]
    }

    // MARK: - 1.2.15 MappingPassCapability

    func startMappingPass() async throws {}

    func getMappingPassProperties() async throws -> VTMappingPassProperties {
        [:]
    }

    func setMapSegmentMaterial(segmentID: String, material: VTMaterial) async throws {
        mapData = VTMapData(
            size: mapData.size,
            pixelSize: mapData.pixelSize,
            layers: mapData.layers.map { layer in
                guard layer.segmentId == segmentID else { return layer }
                var metaData = layer.metaData
                metaData["material"] = .string(material.rawValue)
                return VTLayer(
                    __class: layer.__class,
                    metaData: metaData,
                    type: layer.type,
                    pixels: layer.pixels,
                    compressedPixels: layer.compressedPixels,
                    dimensions: layer.dimensions
                )
            },
            entities: mapData.entities,
            metaData: mapData.metaData
        )
    }

    func getVirtualRestrictions() async throws -> VTVirtualRestrictions {
        let virtualWalls = mapData.entities.compactMap { entity -> VTVirtualWallPayload? in
            guard entity.type == .virtual_wall, entity.points.count >= 4 else { return nil }
            return VTVirtualWallPayload(
                points: VTVirtualWallPoints(
                    pA: VTMapCoordinate(x: entity.points[0], y: entity.points[1]),
                    pB: VTMapCoordinate(x: entity.points[2], y: entity.points[3])
                )
            )
        }

        let restrictedZones = mapData.entities.compactMap { entity -> VTRestrictionsZonePayload? in
            guard entity.points.count >= 8 else { return nil }

            let type: VTVirtualRestrictionsZoneType
            switch entity.type {
            case .no_go_area:
                type = .regular
            case .no_mop_area:
                type = .mop
            default:
                return nil
            }

            return VTRestrictionsZonePayload(
                type: type,
                points: VTRectangularZonePoints(
                    pA: VTMapCoordinate(x: entity.points[0], y: entity.points[1]),
                    pB: VTMapCoordinate(x: entity.points[2], y: entity.points[3]),
                    pC: VTMapCoordinate(x: entity.points[4], y: entity.points[5]),
                    pD: VTMapCoordinate(x: entity.points[6], y: entity.points[7])
                )
            )
        }

        return VTVirtualRestrictions(virtualWalls: virtualWalls, restrictedZones: restrictedZones)
    }

    func setVirtualRestrictions(_ restrictions: VTVirtualRestrictions) async throws {
        let retainedEntities = mapData.entities.filter {
            switch $0.type {
            case .no_go_area, .no_mop_area, .virtual_wall: false
            default: true
            }
        }

        let virtualWallEntities = restrictions.virtualWalls.map { wall in
            VTEntity(
                __class: "LineMapEntity",
                metaData: [:],
                type: .virtual_wall,
                points: [
                    wall.points.pA.x,
                    wall.points.pA.y,
                    wall.points.pB.x,
                    wall.points.pB.y,
                ]
            )
        }

        let restrictedZoneEntities = restrictions.restrictedZones.map { zone in
            VTEntity(
                __class: "PolygonMapEntity",
                metaData: [:],
                type: zone.type == .regular ? .no_go_area : .no_mop_area,
                points: [
                    zone.points.pA.x,
                    zone.points.pA.y,
                    zone.points.pB.x,
                    zone.points.pB.y,
                    zone.points.pC.x,
                    zone.points.pC.y,
                    zone.points.pD.x,
                    zone.points.pD.y,
                ]
            )
        }

        mapData = VTMapData(
            size: mapData.size,
            pixelSize: mapData.pixelSize,
            layers: mapData.layers,
            entities: retainedEntities + virtualWallEntities + restrictedZoneEntities,
            metaData: mapData.metaData
        )
    }

    func getVirtualRestrictionsProperties() async throws -> VTVirtualRestrictionsProperties {
        VTVirtualRestrictionsProperties(supportedRestrictedZoneTypes: [.regular, .mop])
    }

    func getKeyLockIsEnabled() async throws -> Bool {
        keyLockEnabled
    }

    func enableKeyLock() async throws {
        keyLockEnabled = true
    }

    func disableKeyLock() async throws {
        keyLockEnabled = false
    }

    func getKeyLockProperties() async throws -> [String: VTAnyCodable] {
        [:]
    }

    func locateRobot() async throws {}

    func getLocateRobotProperties() async throws -> VTLocateRobotProperties {
        emptyProperties
    }

    func goTo(x _: Int, y _: Int) async throws {}

    func getGoToProperties() async throws -> VTGoToProperties {
        emptyProperties
    }

    func getAutoEmptyDockAutoEmptyDuration() async throws -> VTAutoEmptyDockAutoEmptyDuration {
        autoEmptyDockAutoEmptyDuration
    }

    func setAutoEmptyDockAutoEmptyDuration(_ duration: VTAutoEmptyDockAutoEmptyDuration) async throws {
        autoEmptyDockAutoEmptyDuration = duration
    }

    func getAutoEmptyDockAutoEmptyDurationProperties() async throws -> VTAutoEmptyDockAutoEmptyDurationProperties {
        VTAutoEmptyDockAutoEmptyDurationProperties(supportedDurations: [.auto, .short, .medium, .long])
    }

    func getAutoEmptyDockAutoEmptyInterval() async throws -> VTAutoEmptyDockAutoEmptyInterval {
        autoEmptyDockAutoEmptyInterval
    }

    func setAutoEmptyDockAutoEmptyInterval(_ interval: VTAutoEmptyDockAutoEmptyInterval) async throws {
        autoEmptyDockAutoEmptyInterval = interval
    }

    func getAutoEmptyDockAutoEmptyIntervalProperties() async throws -> VTAutoEmptyDockAutoEmptyIntervalProperties {
        VTAutoEmptyDockAutoEmptyIntervalProperties(supportedIntervals: [.off, .infrequent, .normal, .frequent])
    }

    func getAutoEmptyDockManualTriggerCapabilityProperties() async throws -> VTAutoEmptyDockManualTriggerCapabilityProperties {
        emptyProperties
    }

    func getCarpetSensorMode() async throws -> VTCarpetSensorMode {
        carpetSensorMode
    }

    func setCarpetSensorMode(_ mode: VTCarpetSensorMode) async throws {
        carpetSensorMode = mode
    }

    func getCarpetSensorModeControlProperties() async throws -> VTCarpetSensorModeControlProperties {
        VTCarpetSensorModeControlProperties(supportedModes: [.off, .avoid, .lift, .detach])
    }

    func getCleanRoute() async throws -> VTCleanRoute {
        cleanRoute
    }

    func setCleanRoute(_ route: VTCleanRoute) async throws {
        cleanRoute = route
    }

    func getCleanRouteControlProperties() async throws -> VTCleanRouteControlProperties {
        VTCleanRouteControlProperties(
            supportedRoutes: [.normal, .quick, .intensive, .deep],
            mopOnly: [.normal, .quick],
            oneTime: [.intensive, .deep]
        )
    }

    func getDoNotDisturbConfiguration() async throws -> VTDoNotDisturbConfiguration {
        doNotDisturbConfiguration
    }

    func setDoNotDisturbConfiguration(_ configuration: VTDoNotDisturbConfiguration) async throws {
        doNotDisturbConfiguration = configuration
    }

    func getDoNotDisturbCapabilityProperties() async throws -> VTDoNotDisturbCapabilityProperties {
        emptyProperties
    }

    func getMapSnapshots() async throws -> [VTMapSnapshot] {
        mapSnapshots
    }

    func restoreMapSnapshot(id: String) async throws {
        guard let snapshot = mapSnapshots.first(where: { $0.id == id }) else {
            throw VTAPIError.missingID(String(describing: VTMapSnapshot.self))
        }
        mapData = snapshot.map
    }

    func getMapSnapshotCapabilityProperties() async throws -> VTMapSnapshotCapabilityProperties {
        emptyProperties
    }

    func getMopDockMopDryingDuration() async throws -> VTMopDockMopDryingDuration {
        mopDockMopDryingDuration
    }

    func setMopDockMopDryingDuration(_ duration: VTMopDockMopDryingDuration) async throws {
        mopDockMopDryingDuration = duration
    }

    func getMopDockMopDryingTimeControlProperties() async throws -> VTMopDockMopDryingTimeControlProperties {
        VTMopDockMopDryingTimeControlProperties(supportedDurations: [.twoHours, .threeHours, .fourHours, .cold])
    }

    func getMopDockMopWashTemperature() async throws -> VTMopDockMopWashTemperature {
        mopDockMopWashTemperature
    }

    func setMopDockMopWashTemperature(_ temperature: VTMopDockMopWashTemperature) async throws {
        mopDockMopWashTemperature = temperature
    }

    func getMopDockMopWashTemperatureControlProperties() async throws -> VTMopDockMopWashTemperatureControlProperties {
        VTMopDockMopWashTemperatureControlProperties(supportedTemperatures: [.cold, .warm, .hot, .scalding, .boiling])
    }

    func getPendingMapChangeHandlingIsEnabled() async throws -> Bool {
        toggleCapabilityStates["PendingMapChangeHandlingCapability"] ?? false
    }

    func acceptPendingMapChange() async throws {
        toggleCapabilityStates["PendingMapChangeHandlingCapability"] = false
    }

    func rejectPendingMapChange() async throws {
        toggleCapabilityStates["PendingMapChangeHandlingCapability"] = false
    }

    func getPendingMapChangeHandlingCapabilityProperties() async throws -> VTPendingMapChangeHandlingCapabilityProperties {
        emptyProperties
    }

    func getFanSpeedControlProperties() async throws -> VTFanSpeedControlCapabilityProperties {
        emptyProperties
    }

    func getWaterUsageControlProperties() async throws -> VTWaterUsageControlCapabilityProperties {
        emptyProperties
    }

    func getOperationModeControlProperties() async throws -> VTOperationModeControlCapabilityProperties {
        emptyProperties
    }

    func getQuirks() async throws -> [VTQuirk] {
        Array(quirks.values)
    }

    func setQuirk(id: String, value: String) async throws {
        if let quirk = quirks[id] {
            quirks[id] = VTQuirk(
                id: quirk.id,
                options: quirk.options,
                title: quirk.title,
                description: quirk.description,
                value: value
            )
        }
    }

    func getQuirksCapabilityProperties() async throws -> VTQuirksCapabilityProperties {
        emptyProperties
    }

    func getCarpetModeIsEnabled() async throws -> Bool {
        toggleState(for: "CarpetModeControlCapability")
    }

    func enableCarpetMode() async throws {
        setToggleState(for: "CarpetModeControlCapability", enabled: true)
    }

    func disableCarpetMode() async throws {
        setToggleState(for: "CarpetModeControlCapability", enabled: false)
    }

    func getCarpetModeControlProperties() async throws -> VTCarpetModeControlCapabilityProperties {
        emptyProperties
    }

    func getPersistentMapIsEnabled() async throws -> Bool {
        toggleState(for: "PersistentMapControlCapability")
    }

    func enablePersistentMap() async throws {
        setToggleState(for: "PersistentMapControlCapability", enabled: true)
    }

    func disablePersistentMap() async throws {
        setToggleState(for: "PersistentMapControlCapability", enabled: false)
    }

    func getPersistentMapControlProperties() async throws -> VTPersistentMapControlCapabilityProperties {
        emptyProperties
    }

    func getObstacleAvoidanceIsEnabled() async throws -> Bool {
        toggleState(for: "ObstacleAvoidanceControlCapability")
    }

    func enableObstacleAvoidance() async throws {
        setToggleState(for: "ObstacleAvoidanceControlCapability", enabled: true)
    }

    func disableObstacleAvoidance() async throws {
        setToggleState(for: "ObstacleAvoidanceControlCapability", enabled: false)
    }

    func getObstacleAvoidanceControlProperties() async throws -> VTObstacleAvoidanceControlCapabilityProperties {
        emptyProperties
    }

    func getPetObstacleAvoidanceIsEnabled() async throws -> Bool {
        toggleState(for: "PetObstacleAvoidanceControlCapability")
    }

    func enablePetObstacleAvoidance() async throws {
        setToggleState(for: "PetObstacleAvoidanceControlCapability", enabled: true)
    }

    func disablePetObstacleAvoidance() async throws {
        setToggleState(for: "PetObstacleAvoidanceControlCapability", enabled: false)
    }

    func getPetObstacleAvoidanceControlProperties() async throws -> VTPetObstacleAvoidanceControlCapabilityProperties {
        emptyProperties
    }

    func getCollisionAvoidantNavigationIsEnabled() async throws -> Bool {
        toggleState(for: "CollisionAvoidantNavigationControlCapability")
    }

    func enableCollisionAvoidantNavigation() async throws {
        setToggleState(for: "CollisionAvoidantNavigationControlCapability", enabled: true)
    }

    func disableCollisionAvoidantNavigation() async throws {
        setToggleState(for: "CollisionAvoidantNavigationControlCapability", enabled: false)
    }

    func getCollisionAvoidantNavigationControlProperties() async throws -> VTCollisionAvoidantNavigationControlCapabilityProperties {
        emptyProperties
    }

    func getMopExtensionIsEnabled() async throws -> Bool {
        toggleState(for: "MopExtensionControlCapability")
    }

    func enableMopExtension() async throws {
        setToggleState(for: "MopExtensionControlCapability", enabled: true)
    }

    func disableMopExtension() async throws {
        setToggleState(for: "MopExtensionControlCapability", enabled: false)
    }

    func getMopExtensionControlProperties() async throws -> VTMopExtensionControlCapabilityProperties {
        emptyProperties
    }

    func getCameraLightIsEnabled() async throws -> Bool {
        toggleState(for: "CameraLightControlCapability")
    }

    func enableCameraLight() async throws {
        setToggleState(for: "CameraLightControlCapability", enabled: true)
    }

    func disableCameraLight() async throws {
        setToggleState(for: "CameraLightControlCapability", enabled: false)
    }

    func getCameraLightControlProperties() async throws -> VTCameraLightControlCapabilityProperties {
        emptyProperties
    }

    func getMopTwistIsEnabled() async throws -> Bool {
        toggleState(for: "MopTwistControlCapability")
    }

    func enableMopTwist() async throws {
        setToggleState(for: "MopTwistControlCapability", enabled: true)
    }

    func disableMopTwist() async throws {
        setToggleState(for: "MopTwistControlCapability", enabled: false)
    }

    func getMopTwistControlProperties() async throws -> VTMopTwistControlCapabilityProperties {
        emptyProperties
    }

    func getMopExtensionFurnitureLegHandlingIsEnabled() async throws -> Bool {
        toggleState(for: "MopExtensionFurnitureLegHandlingControlCapability")
    }

    func enableMopExtensionFurnitureLegHandling() async throws {
        setToggleState(for: "MopExtensionFurnitureLegHandlingControlCapability", enabled: true)
    }

    func disableMopExtensionFurnitureLegHandling() async throws {
        setToggleState(for: "MopExtensionFurnitureLegHandlingControlCapability", enabled: false)
    }

    func getMopExtensionFurnitureLegHandlingControlProperties() async throws -> VTMopExtensionFurnitureLegHandlingControlCapabilityProperties {
        emptyProperties
    }

    func getMopDockMopAutoDryingIsEnabled() async throws -> Bool {
        toggleState(for: "MopDockMopAutoDryingControlCapability")
    }

    func enableMopDockMopAutoDrying() async throws {
        setToggleState(for: "MopDockMopAutoDryingControlCapability", enabled: true)
    }

    func disableMopDockMopAutoDrying() async throws {
        setToggleState(for: "MopDockMopAutoDryingControlCapability", enabled: false)
    }

    func getMopDockMopAutoDryingControlProperties() async throws -> VTMopDockMopAutoDryingControlCapabilityProperties {
        emptyProperties
    }

    func getFloorMaterialDirectionAwareNavigationIsEnabled() async throws -> Bool {
        toggleState(for: "FloorMaterialDirectionAwareNavigationControlCapability")
    }

    func enableFloorMaterialDirectionAwareNavigation() async throws {
        setToggleState(for: "FloorMaterialDirectionAwareNavigationControlCapability", enabled: true)
    }

    func disableFloorMaterialDirectionAwareNavigation() async throws {
        setToggleState(for: "FloorMaterialDirectionAwareNavigationControlCapability", enabled: false)
    }

    func getFloorMaterialDirectionAwareNavigationControlProperties() async throws -> VTFloorMaterialDirectionAwareNavigationControlCapabilityProperties {
        emptyProperties
    }

    func playSpeakerTestSound() async throws {}

    func getSpeakerTestCapabilityProperties() async throws -> VTSpeakerTestCapabilityProperties {
        emptyProperties
    }

    func getSpeakerVolume() async throws -> Int {
        speakerVolume
    }

    func setSpeakerVolume(_ volume: Int) async throws {
        speakerVolume = volume
    }

    func getSpeakerVolumeControlProperties() async throws -> VTSpeakerVolumeControlCapabilityProperties {
        emptyProperties
    }

    func getTotalStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        [
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .time, value: 654_321),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .area, value: 9_876_543),
            VTValetudoDataPoint(__class: "ValetudoDataPoint", metaData: [:], timestamp: Date(), type: .count, value: 314),
        ]
    }

    func getTotalStatisticsCapabilityProperties() async throws -> VTStatisticsCapabilityProperties {
        VTStatisticsCapabilityProperties(availableStatistics: [.count, .time, .area])
    }

    func getVoicePackManagementStatus() async throws -> VTVoicePackManagementStatus {
        voicePackManagementStatus
    }

    func downloadVoicePack(url _: String, language: String, hash _: String) async throws {
        voicePackManagementStatus = VTVoicePackManagementStatus(
            currentLanguage: language,
            operationStatus: VTVoicePackOperationStatus(type: .downloading, progress: 100, metaData: [:])
        )
    }

    func getVoicePackManagementCapabilityProperties() async throws -> VTVoicePackManagementCapabilityProperties {
        emptyProperties
    }

    func getWifiConfiguration() async throws -> VTWifiConfiguration {
        wifiConfiguration
    }

    func setWifiConfiguration(_ configuration: VTWifiConfigurationAction) async throws {
        wifiConfiguration = VTWifiConfiguration(
            state: .connected,
            details: VTWifiDetails(
                ssid: configuration.ssid,
                bssid: wifiConfiguration.details?.bssid,
                downspeed: wifiConfiguration.details?.downspeed,
                upspeed: wifiConfiguration.details?.upspeed,
                signal: wifiConfiguration.details?.signal,
                ips: wifiConfiguration.details?.ips,
                frequency: wifiConfiguration.details?.frequency
            ),
            metaData: configuration.metaData ?? [:]
        )
    }

    func getWifiConfigurationCapabilityProperties() async throws -> VTWifiConfigurationCapabilityProperties {
        VTWifiConfigurationCapabilityProperties(provisionedReconfigurationSupported: true)
    }

    func getWifiNetworks() async throws -> [VTWifiScanResult] {
        wifiNetworks
    }

    func getWifiScanCapabilityProperties() async throws -> VTWifiScanCapabilityProperties {
        emptyProperties
    }

    func clean(zones _: [VTZoneCleaningZone], iterations _: Int) async throws {}

    func getZoneCleaningCapabilityProperties() async throws -> VTZoneCleaningCapabilityProperties {
        VTZoneCleaningCapabilityProperties(
            zoneCount: VTZoneCleaningCountRange(min: 1, max: 5),
            iterationCount: VTZoneCleaningCountRange(min: 1, max: 3)
        )
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

    func getLog() async throws -> [VTLogEntry] {
        [
            VTLogEntry(timestamp: Date(), level: "info", message: "Mock client started"),
            VTLogEntry(timestamp: Date(), level: "debug", message: "Mock log entry"),
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

    private func toggleState(for capability: String) -> Bool {
        toggleCapabilityStates[capability] ?? false
    }

    private func setToggleState(for capability: String, enabled: Bool) {
        toggleCapabilityStates[capability] = enabled
    }

    private func storeObserverTask(_ task: Task<Void, Never>, for token: VTListenerToken) {
        observerTasks[token] = task
    }

    private func emitEvent<O>(for endpoint: VTEventEndpoint<some Decodable & Equatable, O>, to continuation: AsyncStream<VTEventAction<O>>.Continuation) {
        switch endpoint.eventID {
        case .stateAttributes:
            yield(stateAttributes, to: continuation)
        case .map:
            yield(mapData, to: continuation)
        case .valetudoEvent:
            yield(events, to: continuation)
        case .log:
            yield([
                VTLogEntry(timestamp: Date(), level: "info", message: "Mock client started"),
                VTLogEntry(timestamp: Date(), level: "debug", message: "Mock log entry"),
            ], to: continuation)
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

    private static func makeMockMap() -> VTMapData {
        do {
            return try JSONDecoder().decode(VTMapData.self, from: Data(VTMockMapData.mapJSON.utf8))
        } catch {
            log(message: "Failed to decode mock map data: \(error.localizedDescription)", forSubsystem: .mock, level: .error)
            return VTMapData(size: VTSize(x: 0, y: 0), pixelSize: 1, layers: [], entities: [], metaData: VTMetaData(version: 2))
        }
    }
}
