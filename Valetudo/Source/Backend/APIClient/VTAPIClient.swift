import CoreGraphics
import CoreImage
import Foundation
import Network

private enum VTHTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

private struct VTRequest<Response> {
    enum MimeType: String {
        case json = "application/json"
        case jpeg = "image/jpeg"
    }

    var method: VTHTTPMethod
    var url: URL?
    var query: [String: String]?
    var body: Encodable?
    var contentType: MimeType = .json
    var accept: MimeType = .json
}

enum VTAPIError: Error, LocalizedError {
    case clientUnavailable
    case unknown(Error)
    case missingID(String)
    case manualControlStateUnavailable
    case noDictionary

    var errorDescription: String? {
        switch self {
        case .clientUnavailable: "The API client is not available."
        case .manualControlStateUnavailable: "Could not read the manual control state."
        case let .missingID(domain): "Missing id for \(domain)."
        case let .unknown(error): error.localizedDescription
        case .noDictionary: "Unexpected non-dictionary response"
        }
    }
}

public actor VTAPIClient: VTAPIClientProtocol {
    // MARK: - URLs

    let baseURL: URL
    let valetudoURL: URL
    let robotURL: URL
    let stateURL: URL
    let capabilitiesURL: URL
    let systemURL: URL
    let hostURL: URL
    let runtimeURL: URL
    let updaterURL: URL
    let logURL: URL
    let timersURL: URL
    let eventsURL: URL
    let networkAdvertisementURL: URL

    // MARK: - (SSE) Server side events

    lazy var eventSockets: [VTEventEndpointEventID: any VTEventSocketProtocol] = [:]

    // MARK: - Requests

    private let session: URLSession
    private let encoder = JSONEncoder()
    private let headers: [String: String] = [:] // Default empty headers. Customize if needed.

    init(baseURL: URL, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("v2")
        robotURL = self.baseURL
            .appendingPathComponent("robot")
        stateURL = robotURL
            .appendingPathComponent("state")
        capabilitiesURL = robotURL
            .appendingPathComponent("capabilities")
        systemURL = self.baseURL
            .appendingPathComponent("system")
        hostURL = systemURL
            .appendingPathComponent("host")
        runtimeURL = systemURL
            .appendingPathComponent("runtime")
        valetudoURL = self.baseURL
            .appendingPathComponent("valetudo")
        updaterURL = self.baseURL
            .appendingPathComponent("updater")
        logURL = valetudoURL
            .appendingPathComponent("log")
        timersURL = self.baseURL
            .appendingPathComponent("timers")
        eventsURL = self.baseURL
            .appendingPathComponent("events")
        networkAdvertisementURL = self.baseURL
            .appendingPathComponent("networkadvertisement")

        session = URLSession(configuration: configuration)
    }

    // MARK: - 1. Robot

    public func getRobotInfo() async throws -> VTRobotInfo {
        let infoRequest = VTRequest<VTRobotInfo>(method: .GET, url: robotURL, query: nil, body: nil)
        return try await send(infoRequest)
    }

    // MARK: - 1.1 State

    // MARK: - 1.1.1 Attributes

    public func getStateAttributes() async throws -> VTStateAttributeList {
        let url = stateURL.appendingPathComponent("attributes")
        let stateAttributesRequest = VTRequest<VTStateAttributeList>(method: .GET, url: url, query: nil, body: nil)
        return try await send(stateAttributesRequest)
    }

    // MARK: - 1.1.2 Map

    public func getMap() async throws -> VTMapData {
        let url = stateURL.appendingPathComponent("map")
        let mapRequest = VTRequest<VTMapData>(method: .GET, url: url, query: nil, body: nil)
        return try await send(mapRequest)
    }

    // MARK: - 1.2 Capabilities

    public func getCapabilities() async throws -> [VTCapability] {
        let url = capabilitiesURL
        let capabilitiesRequest = VTRequest<[VTCapability]>(method: .GET, url: url, query: nil, body: nil)
        return try await send(capabilitiesRequest)
    }

    // MARK: - 1.2.1 CurrentStatisticsCapability

    public func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        let url = capabilitiesURL.appendingPathComponent("CurrentStatisticsCapability")
        let statisticsRequest = VTRequest<[VTValetudoDataPoint]>(method: .GET, url: url, query: nil, body: nil)
        return try await send(statisticsRequest)
    }

    public func getCurrentStatisticsCapabilityProperties() async throws -> VTStatisticsCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent("CurrentStatisticsCapability")
            .appendingPathComponent("properties")
        let request = VTRequest<VTStatisticsCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.2 BasicControlCapability

    private let basicControlCapabilityPath: String = "BasicControlCapability"

    public func start() async throws {
        let url = capabilitiesURL.appendingPathComponent(basicControlCapabilityPath)
        let data = VTBasicControlAction(action: .start)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func pause() async throws {
        let url = capabilitiesURL.appendingPathComponent(basicControlCapabilityPath)
        let data = VTBasicControlAction(action: .pause)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func stop() async throws {
        let url = capabilitiesURL.appendingPathComponent(basicControlCapabilityPath)
        let data = VTBasicControlAction(action: .stop)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func home() async throws {
        let url = capabilitiesURL.appendingPathComponent(basicControlCapabilityPath)
        let data = VTBasicControlAction(action: .home)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func getBasicControlCapabilityProperties() async throws -> VTBasicControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(basicControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTBasicControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.3 MapSegmentationCapability

    private let mapSegmentationCapabilityPath: String = "MapSegmentationCapability"

    public func getMapSegments() async throws -> [VTMapSegment] {
        let url = capabilitiesURL.appendingPathComponent(mapSegmentationCapabilityPath)
        let request = VTRequest<[VTMapSegment]>(method: .GET, url: url)
        return try await send(request)
    }

    public func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws {
        let url = capabilitiesURL.appendingPathComponent(mapSegmentationCapabilityPath)
        let data = VTMapSegmentationAction(segmentIDs: segmentIDs, iterations: iterations, customOrder: customOrder)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func getMapSegmentationProperties() async throws -> VTMapSegmentationProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mapSegmentationCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMapSegmentationProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.4 AutoEmptyDockManualTriggerCapability

    private let autoEmptyDockManualTriggerCapabilityPath: String = "AutoEmptyDockManualTriggerCapability"

    public func autoEmptyDock() async throws {
        let url = capabilitiesURL.appendingPathComponent(autoEmptyDockManualTriggerCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTAutoEmptyDockManualTriggerAction())
        try await send(request)
    }

    public func getAutoEmptyDockManualTriggerCapabilityProperties() async throws -> VTAutoEmptyDockManualTriggerCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(autoEmptyDockManualTriggerCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAutoEmptyDockManualTriggerCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.5 MopDockCleanManualTriggerCapability

    private let mopDockCleanCapabilityPath: String = "MopDockCleanManualTriggerCapability"

    public func startMopDockClean() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockCleanCapabilityPath)
        let data = VTMopDockCleanToggleStartStopAction(action: .start)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func stopMopDockClean() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockCleanCapabilityPath)
        let data = VTMopDockCleanToggleStartStopAction(action: .stop)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    // MARK: - 1.2.6 MopDockDryManualTriggerCapability

    private let mopDockDryCapabilityPath: String = "MopDockDryManualTriggerCapability"

    public func startMopDockDry() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockDryCapabilityPath)
        let data = VTMopDockDryToggleStartStopAction(action: .start)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func stopMopDockDry() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockDryCapabilityPath)
        let data = VTMopDockDryToggleStartStopAction(action: .stop)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    // MARK: - 1.2.7 FanSpeedControlCapability / 1.2.8 WaterUsageControlCapability / 1.2.9 OperationModeControlCapability

    private func capabilityPath(forType type: VTPresetType) -> String {
        switch type {
        case .fanSpeed: "FanSpeedControlCapability"
        case .waterGrade: "WaterUsageControlCapability"
        case .operationMode: "OperationModeControlCapability"
        }
    }

    public func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue] {
        let url = capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: type))
            .appendingPathComponent("presets")
        let request = VTRequest<[VTPresetValue]>(method: .GET, url: url, query: nil, body: nil)
        return try await send(request)
    }

    public func setPreset(_ value: VTPresetValue, forType type: VTPresetType) async throws {
        let data = VTPresetAction(name: value)
        let url = capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: type))
            .appendingPathComponent("preset")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    public func getFanSpeedControlProperties() async throws -> VTFanSpeedControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: .fanSpeed))
            .appendingPathComponent("properties")
        let request = VTRequest<VTFanSpeedControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    public func getWaterUsageControlProperties() async throws -> VTWaterUsageControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: .waterGrade))
            .appendingPathComponent("properties")
        let request = VTRequest<VTWaterUsageControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    public func getOperationModeControlProperties() async throws -> VTOperationModeControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: .operationMode))
            .appendingPathComponent("properties")
        let request = VTRequest<VTOperationModeControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.10 ConsumableMonitoringCapability

    private let consumableMonitoringCapabilityPath: String = "ConsumableMonitoringCapability"

    public func getConsumables() async throws -> [VTConsumableState] {
        let url = capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
        let request = VTRequest<VTStateAttributeList>(method: .GET, url: url, query: nil)
        return try await send(request).attributes.compactMap {
            $0 as? VTConsumableState
        }
    }

    public func getPropertiesForConsumables() async throws -> [VTConsumableStateProperties] {
        let url = capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTConsumableStatePropertiesList>(method: .GET, url: url, query: nil)
        return try await send(request).availableConsumables
    }

    public func resetConsumable(type: VTConsumableType) async throws {
        let url = capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
            .appendingPathComponent(type.rawValue)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTResetConsumableAction())
        try await send(request)
    }

    public func resetConsumable(type: VTConsumableType, subtype: VTConsumableSubType) async throws {
        let url = capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
            .appendingPathComponent(type.rawValue)
            .appendingPathComponent(subtype.rawValue)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTResetConsumableAction())
        try await send(request)
    }

    // MARK: - 1.2.11 ManualControlCapability

    private let manualControlCapabilityPath: String = "ManualControlCapability"

    public func getManualControlIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let request = VTRequest<VTManualControlState>(method: .GET, url: url, query: nil)
        if let enabled = try await send(request).enabled {
            return enabled
        }
        throw VTAPIError.manualControlStateUnavailable
    }

    public func getManualControlSupportedMovementDirections() async throws -> [VTMoveDirection] {
        let url = capabilitiesURL
            .appendingPathComponent(manualControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTManualControlState>(method: .GET, url: url, query: nil)
        if let directions = try await send(request).supportedMovementCommands {
            return directions
        }
        throw VTAPIError.manualControlStateUnavailable
    }

    public func enableManualControl() async throws {
        let url = capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTManualControlAction.enable)
        try await send(request)
    }

    public func disableManualControl() async throws {
        let url = capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTManualControlAction.disable)
        try await send(request)
    }

    public func manualControlMove(direction: VTMoveDirection) async throws {
        let url = capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let action = VTManualControlAction.move(direction: direction)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }

    // MARK: - 1.2.12 HighResolutionManualControlCapability

    private let highResolutionManualControlCapabilityPath: String = "HighResolutionManualControlCapability"

    public func getHighResolutionManualControlIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let request = VTRequest<VTHighResolutionManualControlState>(method: .GET, url: url, query: nil)
        return try await send(request).enabled
    }

    public func enableHighResolutionManualControl() async throws {
        let url = capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let action: VTHighResolutionManualControlAction = .enable
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }

    public func disableHighResolutionManualControl() async throws {
        let url = capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let action: VTHighResolutionManualControlAction = .disable
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }

    // angle: +- 180.0 and velocity: +-1.0
    public func highResolutionManualControlMove(angle: CGFloat, velocity: CGFloat) async throws {
        let url = capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let action = VTHighResolutionManualControlAction.move(vector: .init(velocity: velocity, angle: angle))
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }

    public func getHighResolutionManualControlCapabilityProperties() async throws -> VTHighResolutionManualControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(highResolutionManualControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTHighResolutionManualControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.13 ObstacleImagesCapability

    private let obstacleImagesCapabilityPath: String = "ObstacleImagesCapability"

    public func getObstacleImagesCapabilityIsEnabled() async throws -> Bool {
        let url = capabilitiesURL
            .appendingPathComponent(obstacleImagesCapabilityPath)
        let request = VTRequest<VTObstacleImagesState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableObstacleImagesCapability() async throws {
        let url = capabilitiesURL
            .appendingPathComponent(obstacleImagesCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTObstacleImagesAction(action: .enabled))
        return try await send(request)
    }

    public func disableObstacleImagesCapability() async throws {
        let url = capabilitiesURL
            .appendingPathComponent(obstacleImagesCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTObstacleImagesAction(action: .disable))
        return try await send(request)
    }

    public func getObstacleImage(id: String) async throws -> CIImage {
        let url = capabilitiesURL
            .appendingPathComponent(obstacleImagesCapabilityPath)
            .appendingPathComponent("img")
            .appendingPathComponent(id)
        let request = VTRequest<Data>(method: .GET, url: url, accept: .jpeg)
        let binary = try await send(request)
        if let image = CIImage(data: binary) {
            return image
        }
        throw VTAPIError.unknown(URLError(.cannotDecodeContentData))
    }

    public func getObstacleImagesCapabilityProperties() async throws -> VTObstacleImagesProperties {
        let url = capabilitiesURL
            .appendingPathComponent(obstacleImagesCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTObstacleImagesProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.14 MapResetCapability

    private let mapResetCapabilityPath: String = "MapResetCapability"

    public func resetMap() async throws {
        let url = capabilitiesURL
            .appendingPathComponent(mapResetCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMapResetAction())
        return try await send(request)
    }

    /// Seems to be currently unused
    public func getMapResetProperties() async throws -> VTMapResetProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mapResetCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAnyCodable>(method: .GET, url: url)
        guard let dictValue = try await send(request).dictionaryValue else {
            throw VTAPIError.noDictionary
        }
        return dictValue
    }

    // MARK: - 1.2.15 MappingPassCapability

    private let mappingPassCapabilityPath: String = "MappingPassCapability"

    public func startMappingPass() async throws {
        let url = capabilitiesURL
            .appendingPathComponent(mappingPassCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMappingPassAction())
        return try await send(request)
    }

    /// Seems to be currently unused
    public func getMappingPassProperties() async throws -> VTMappingPassProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mappingPassCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAnyCodable>(method: .GET, url: url)
        guard let dictValue = try await send(request).dictionaryValue else {
            throw VTAPIError.noDictionary
        }
        return dictValue
    }

    // MARK: - 1.2.16 MapSegmentMaterialControlCapability

    private let mapSegmentMaterialControlCapabilityPath: String = "MapSegmentMaterialControlCapability"

    public func setMapSegmentMaterial(segmentID: String, material: VTMaterial) async throws {
        let url = capabilitiesURL
            .appendingPathComponent(mapSegmentMaterialControlCapabilityPath)
        let action = VTMapMaterialAction(action: .setMaterial, segmentID: segmentID, material: material)
        let request = VTRequest<Void>(method: .PUT, url: url, body: action)
        return try await send(request)
    }

    public func getSupportedMapSegmentMaterials() async throws -> [VTMaterial] {
        let url = capabilitiesURL
            .appendingPathComponent(mapSegmentMaterialControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMapMaterialProperties>(method: .GET, url: url)
        return try await send(request).supportedMaterials
    }

    // MARK: - 1.2.17 MapSegmentEditCapability

    private let mapSegmentEditCapabilityPath: String = "MapSegmentEditCapability"

    public func joinMapSegments(segmentAID: String, segmentBID: String) async throws {
        let url = capabilitiesURL.appendingPathComponent(mapSegmentEditCapabilityPath)
        let data = VTMapSegmentJoinAction(segmentAID: segmentAID, segmentBID: segmentBID)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    public func splitMapSegment(segmentID: String, pointA: CGPoint, pointB: CGPoint) async throws {
        let url = capabilitiesURL.appendingPathComponent(mapSegmentEditCapabilityPath)
        let mapPointA = VTMapCoordinate(x: Int(pointA.x.rounded()), y: Int(pointA.y.rounded()))
        let mapPointB = VTMapCoordinate(x: Int(pointB.x.rounded()), y: Int(pointB.y.rounded()))
        let data = VTMapSegmentSplitAction(segmentID: segmentID, pointA: mapPointA, pointB: mapPointB)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    /// Seems to be currently unused
    public func getMapSegmentEditProperties() async throws -> VTMapSegmentEditProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mapSegmentEditCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAnyCodable>(method: .GET, url: url)
        guard let dictValue = try await send(request).dictionaryValue else {
            throw VTAPIError.noDictionary
        }
        return dictValue
    }

    // MARK: - 1.2.18 MapSegmentRenameCapability

    private let mapSegmentRenameCapabilityPath: String = "MapSegmentRenameCapability"

    public func renameMapSegment(segmentID: String, name: String) async throws {
        let url = capabilitiesURL.appendingPathComponent(mapSegmentRenameCapabilityPath)
        let data = VTMapSegmentRenameAction(segmentID: segmentID, name: name)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    /// Seems to be currently unused
    public func getMapSegmentRenameProperties() async throws -> VTMapSegmentRenameProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mapSegmentRenameCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAnyCodable>(method: .GET, url: url)
        guard let dictValue = try await send(request).dictionaryValue else {
            throw VTAPIError.noDictionary
        }
        return dictValue
    }

    // MARK: - 1.2.19 CombinedVirtualRestrictionsCapability

    private let combinedVirtualRestrictionsCapabilityPath: String = "CombinedVirtualRestrictionsCapability"

    public func getVirtualRestrictions() async throws -> VTVirtualRestrictions {
        let url = capabilitiesURL.appendingPathComponent(combinedVirtualRestrictionsCapabilityPath)
        let request = VTRequest<VTVirtualRestrictions>(method: .GET, url: url)
        return try await send(request)
    }

    public func setVirtualRestrictions(_ data: VTVirtualRestrictions) async throws {
        let url = capabilitiesURL.appendingPathComponent(combinedVirtualRestrictionsCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    public func getVirtualRestrictionsProperties() async throws -> VTVirtualRestrictionsProperties {
        let url = capabilitiesURL
            .appendingPathComponent(combinedVirtualRestrictionsCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTVirtualRestrictionsProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.20 KeyLockCapability

    private let keyLockCapabilityPath: String = "KeyLockCapability"

    public func getKeyLockIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(keyLockCapabilityPath)
        let request = VTRequest<VTKeyLockState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableKeyLock() async throws {
        let url = capabilitiesURL.appendingPathComponent(keyLockCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTKeyLockAction(action: .enable))
        try await send(request)
    }

    public func disableKeyLock() async throws {
        let url = capabilitiesURL.appendingPathComponent(keyLockCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTKeyLockAction(action: .disable))
        try await send(request)
    }

    /// Seems to be currently unused
    public func getKeyLockProperties() async throws -> VTKeyLockProperties {
        let url = capabilitiesURL
            .appendingPathComponent(keyLockCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTKeyLockProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.21 LocateCapability

    private let locateCapabilityPath: String = "LocateCapability"

    public func locateRobot() async throws {
        let url = capabilitiesURL.appendingPathComponent(locateCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url)
        return try await send(request)
    }

    /// Seems to be currently unused
    public func getLocateRobotProperties() async throws -> VTLocateRobotProperties {
        let url = capabilitiesURL
            .appendingPathComponent(locateCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTLocateRobotProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.22 GoToLocationCapability

    private let goToLocationCapabilityPath: String = "GoToLocationCapability"

    public func goTo(x: Int, y: Int) async throws {
        let url = capabilitiesURL.appendingPathComponent(goToLocationCapabilityPath)
        let data = VTGoToAction(coordinates: VTMapCoordinate(x: x, y: y))
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    public func getGoToProperties() async throws -> VTGoToProperties {
        let url = capabilitiesURL
            .appendingPathComponent(goToLocationCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTGoToProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.23 AutoEmptyDockAutoEmptyDurationControlCapability

    private let autoEmptyDockAutoEmptyDurationControlCapabilityPath: String = "AutoEmptyDockAutoEmptyDurationControlCapability"

    public func getAutoEmptyDockAutoEmptyDuration() async throws -> VTAutoEmptyDockAutoEmptyDuration {
        let url = capabilitiesURL.appendingPathComponent(autoEmptyDockAutoEmptyDurationControlCapabilityPath)
        let request = VTRequest<VTAutoEmptyDockAutoEmptyDurationControlCapabilityState>(method: .GET, url: url)
        return try await send(request).duration
    }

    public func setAutoEmptyDockAutoEmptyDuration(_ duration: VTAutoEmptyDockAutoEmptyDuration) async throws {
        let url = capabilitiesURL.appendingPathComponent(autoEmptyDockAutoEmptyDurationControlCapabilityPath)
        let data = VTAutoEmptyDockAutoEmptyDurationControlCapabilityAction(duration: duration)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    public func getAutoEmptyDockAutoEmptyDurationProperties() async throws -> VTAutoEmptyDockAutoEmptyDurationProperties {
        let url = capabilitiesURL
            .appendingPathComponent(autoEmptyDockAutoEmptyDurationControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAutoEmptyDockAutoEmptyDurationProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.24 AutoEmptyDockAutoEmptyIntervalControlCapability

    private let autoEmptyDockAutoEmptyIntervalControlCapabilityPath: String = "AutoEmptyDockAutoEmptyIntervalControlCapability"

    public func getAutoEmptyDockAutoEmptyInterval() async throws -> VTAutoEmptyDockAutoEmptyInterval {
        let url = capabilitiesURL.appendingPathComponent(autoEmptyDockAutoEmptyIntervalControlCapabilityPath)
        let request = VTRequest<VTAutoEmptyDockAutoEmptyIntervalControlCapabilityState>(method: .GET, url: url)
        return try await send(request).interval
    }

    public func setAutoEmptyDockAutoEmptyInterval(_ interval: VTAutoEmptyDockAutoEmptyInterval) async throws {
        let url = capabilitiesURL.appendingPathComponent(autoEmptyDockAutoEmptyIntervalControlCapabilityPath)
        let data = VTAutoEmptyDockAutoEmptyIntervalControlCapabilityAction(interval: interval)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    public func getAutoEmptyDockAutoEmptyIntervalProperties() async throws -> VTAutoEmptyDockAutoEmptyIntervalProperties {
        let url = capabilitiesURL
            .appendingPathComponent(autoEmptyDockAutoEmptyIntervalControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTAutoEmptyDockAutoEmptyIntervalProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.25 CarpetSensorModeControlCapability

    private let carpetSensorModeControlCapabilityPath: String = "CarpetSensorModeControlCapability"

    public func getCarpetSensorMode() async throws -> VTCarpetSensorMode {
        let url = capabilitiesURL.appendingPathComponent(carpetSensorModeControlCapabilityPath)
        let request = VTRequest<VTCarpetSensorModeState>(method: .GET, url: url)
        return try await send(request).mode
    }

    public func setCarpetSensorMode(_ mode: VTCarpetSensorMode) async throws {
        let url = capabilitiesURL.appendingPathComponent(carpetSensorModeControlCapabilityPath)
        let data = VTCarpetSensorModeAction(mode: mode)
        let request = VTRequest<Void>(method: .PUT, url: url, body: data)
        try await send(request)
    }

    public func getCarpetSensorModeControlProperties() async throws -> VTCarpetSensorModeControlProperties {
        let url = capabilitiesURL
            .appendingPathComponent(carpetSensorModeControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTCarpetSensorModeControlProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.26 CleanRouteControlCapability

    private let cleanRouteControlCapabilityPath: String = "CleanRouteControlCapability"

    public func getCleanRoute() async throws -> VTCleanRoute {
        let url = capabilitiesURL.appendingPathComponent(cleanRouteControlCapabilityPath)
        let request = VTRequest<VTCleanRouteState>(method: .GET, url: url)
        return try await send(request).route
    }

    public func setCleanRoute(_ route: VTCleanRoute) async throws {
        let url = capabilitiesURL.appendingPathComponent(cleanRouteControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCleanRouteAction(route: route))
        try await send(request)
    }

    public func getCleanRouteControlProperties() async throws -> VTCleanRouteControlProperties {
        let url = capabilitiesURL
            .appendingPathComponent(cleanRouteControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTCleanRouteControlProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.27 DoNotDisturbCapability

    private let doNotDisturbCapabilityPath: String = "DoNotDisturbCapability"

    public func getDoNotDisturbConfiguration() async throws -> VTDoNotDisturbConfiguration {
        let url = capabilitiesURL.appendingPathComponent(doNotDisturbCapabilityPath)
        let request = VTRequest<VTDoNotDisturbConfiguration>(method: .GET, url: url)
        return try await send(request)
    }

    public func setDoNotDisturbConfiguration(_ configuration: VTDoNotDisturbConfiguration) async throws {
        let url = capabilitiesURL.appendingPathComponent(doNotDisturbCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: configuration)
        try await send(request)
    }

    public func getDoNotDisturbCapabilityProperties() async throws -> VTDoNotDisturbCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(doNotDisturbCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTDoNotDisturbCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.28 MapSnapshotCapability

    private let mapSnapshotCapabilityPath: String = "MapSnapshotCapability"

    public func getMapSnapshots() async throws -> [VTMapSnapshot] {
        let url = capabilitiesURL.appendingPathComponent(mapSnapshotCapabilityPath)
        let request = VTRequest<[VTMapSnapshot]>(method: .GET, url: url)
        return try await send(request)
    }

    public func restoreMapSnapshot(id: String) async throws {
        let url = capabilitiesURL.appendingPathComponent(mapSnapshotCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMapSnapshotAction(action: .restore, id: id))
        try await send(request)
    }

    public func getMapSnapshotCapabilityProperties() async throws -> VTMapSnapshotCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mapSnapshotCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMapSnapshotCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.29 MopDockMopDryingTimeControlCapability

    private let mopDockMopDryingTimeControlCapabilityPath: String = "MopDockMopDryingTimeControlCapability"

    public func getMopDockMopDryingDuration() async throws -> VTMopDockMopDryingDuration {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopDryingTimeControlCapabilityPath)
        let request = VTRequest<VTMopDockMopDryingTimeControlCapabilityState>(method: .GET, url: url)
        return try await send(request).duration
    }

    public func setMopDockMopDryingDuration(_ duration: VTMopDockMopDryingDuration) async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopDryingTimeControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopDockMopDryingTimeControlCapabilityAction(duration: duration))
        try await send(request)
    }

    public func getMopDockMopDryingTimeControlProperties() async throws -> VTMopDockMopDryingTimeControlProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mopDockMopDryingTimeControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMopDockMopDryingTimeControlProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.30 MopDockMopWashTemperatureControlCapability

    private let mopDockMopWashTemperatureControlCapabilityPath: String = "MopDockMopWashTemperatureControlCapability"

    public func getMopDockMopWashTemperature() async throws -> VTMopDockMopWashTemperature {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopWashTemperatureControlCapabilityPath)
        let request = VTRequest<VTMopDockMopWashTemperatureControlCapabilityState>(method: .GET, url: url)
        return try await send(request).temperature
    }

    public func setMopDockMopWashTemperature(_ temperature: VTMopDockMopWashTemperature) async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopWashTemperatureControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopDockMopWashTemperatureControlCapabilityAction(temperature: temperature))
        try await send(request)
    }

    public func getMopDockMopWashTemperatureControlProperties() async throws -> VTMopDockMopWashTemperatureControlProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mopDockMopWashTemperatureControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMopDockMopWashTemperatureControlProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.31 PendingMapChangeHandlingCapability

    private let pendingMapChangeHandlingCapabilityPath: String = "PendingMapChangeHandlingCapability"

    public func getPendingMapChangeHandlingIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(pendingMapChangeHandlingCapabilityPath)
        let request = VTRequest<VTPendingMapChangeHandlingCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func acceptPendingMapChange() async throws {
        let url = capabilitiesURL.appendingPathComponent(pendingMapChangeHandlingCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTPendingMapChangeHandlingAction(action: .accept))
        try await send(request)
    }

    public func rejectPendingMapChange() async throws {
        let url = capabilitiesURL.appendingPathComponent(pendingMapChangeHandlingCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTPendingMapChangeHandlingAction(action: .reject))
        try await send(request)
    }

    public func getPendingMapChangeHandlingCapabilityProperties() async throws -> VTPendingMapChangeHandlingCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(pendingMapChangeHandlingCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTPendingMapChangeHandlingCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.32 QuirksCapability

    private let quirksCapabilityPath: String = "QuirksCapability"

    public func getQuirk() async throws -> VTQuirk {
        let url = capabilitiesURL.appendingPathComponent(quirksCapabilityPath)
        let request = VTRequest<VTQuirk>(method: .GET, url: url)
        return try await send(request)
    }

    public func setQuirk(id: String, value: String) async throws {
        let url = capabilitiesURL.appendingPathComponent(quirksCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTQuirkAction(id: id, value: value))
        try await send(request)
    }

    public func getQuirksCapabilityProperties() async throws -> VTQuirksCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(quirksCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTQuirksCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.33 CarpetModeControlCapability

    private let carpetModeControlCapabilityPath: String = "CarpetModeControlCapability"

    public func getCarpetModeIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(carpetModeControlCapabilityPath)
        let request = VTRequest<VTCarpetModeControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableCarpetMode() async throws {
        let url = capabilitiesURL.appendingPathComponent(carpetModeControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCarpetModeControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableCarpetMode() async throws {
        let url = capabilitiesURL.appendingPathComponent(carpetModeControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCarpetModeControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getCarpetModeControlProperties() async throws -> VTCarpetModeControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(carpetModeControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTCarpetModeControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.34 PersistentMapControlCapability

    private let persistentMapControlCapabilityPath: String = "PersistentMapControlCapability"

    public func getPersistentMapIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(persistentMapControlCapabilityPath)
        let request = VTRequest<VTPersistentMapControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enablePersistentMap() async throws {
        let url = capabilitiesURL.appendingPathComponent(persistentMapControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTPersistentMapControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disablePersistentMap() async throws {
        let url = capabilitiesURL.appendingPathComponent(persistentMapControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTPersistentMapControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getPersistentMapControlProperties() async throws -> VTPersistentMapControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(persistentMapControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTPersistentMapControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.35 ObstacleAvoidanceControlCapability

    private let obstacleAvoidanceControlCapabilityPath: String = "ObstacleAvoidanceControlCapability"

    public func getObstacleAvoidanceIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(obstacleAvoidanceControlCapabilityPath)
        let request = VTRequest<VTObstacleAvoidanceControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableObstacleAvoidance() async throws {
        let url = capabilitiesURL.appendingPathComponent(obstacleAvoidanceControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTObstacleAvoidanceControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableObstacleAvoidance() async throws {
        let url = capabilitiesURL.appendingPathComponent(obstacleAvoidanceControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTObstacleAvoidanceControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getObstacleAvoidanceControlProperties() async throws -> VTObstacleAvoidanceControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(obstacleAvoidanceControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTObstacleAvoidanceControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.36 PetObstacleAvoidanceControlCapability

    private let petObstacleAvoidanceControlCapabilityPath: String = "PetObstacleAvoidanceControlCapability"

    public func getPetObstacleAvoidanceIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(petObstacleAvoidanceControlCapabilityPath)
        let request = VTRequest<VTPetObstacleAvoidanceControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enablePetObstacleAvoidance() async throws {
        let url = capabilitiesURL.appendingPathComponent(petObstacleAvoidanceControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTPetObstacleAvoidanceControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disablePetObstacleAvoidance() async throws {
        let url = capabilitiesURL.appendingPathComponent(petObstacleAvoidanceControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTPetObstacleAvoidanceControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getPetObstacleAvoidanceControlProperties() async throws -> VTPetObstacleAvoidanceControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(petObstacleAvoidanceControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTPetObstacleAvoidanceControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.37 CollisionAvoidantNavigationControlCapability

    private let collisionAvoidantNavigationControlCapabilityPath: String = "CollisionAvoidantNavigationControlCapability"

    public func getCollisionAvoidantNavigationIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(collisionAvoidantNavigationControlCapabilityPath)
        let request = VTRequest<VTCollisionAvoidantNavigationControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableCollisionAvoidantNavigation() async throws {
        let url = capabilitiesURL.appendingPathComponent(collisionAvoidantNavigationControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCollisionAvoidantNavigationControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableCollisionAvoidantNavigation() async throws {
        let url = capabilitiesURL.appendingPathComponent(collisionAvoidantNavigationControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCollisionAvoidantNavigationControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getCollisionAvoidantNavigationControlProperties() async throws -> VTCollisionAvoidantNavigationControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(collisionAvoidantNavigationControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTCollisionAvoidantNavigationControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.38 MopExtensionControlCapability

    private let mopExtensionControlCapabilityPath: String = "MopExtensionControlCapability"

    public func getMopExtensionIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(mopExtensionControlCapabilityPath)
        let request = VTRequest<VTMopExtensionControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableMopExtension() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopExtensionControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopExtensionControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableMopExtension() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopExtensionControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopExtensionControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getMopExtensionControlProperties() async throws -> VTMopExtensionControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mopExtensionControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMopExtensionControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.39 CameraLightControlCapability

    private let cameraLightControlCapabilityPath: String = "CameraLightControlCapability"

    public func getCameraLightIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(cameraLightControlCapabilityPath)
        let request = VTRequest<VTCameraLightControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableCameraLight() async throws {
        let url = capabilitiesURL.appendingPathComponent(cameraLightControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCameraLightControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableCameraLight() async throws {
        let url = capabilitiesURL.appendingPathComponent(cameraLightControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTCameraLightControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getCameraLightControlProperties() async throws -> VTCameraLightControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(cameraLightControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTCameraLightControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.40 MopTwistControlCapability

    private let mopTwistControlCapabilityPath: String = "MopTwistControlCapability"

    public func getMopTwistIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(mopTwistControlCapabilityPath)
        let request = VTRequest<VTMopTwistControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableMopTwist() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopTwistControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopTwistControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableMopTwist() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopTwistControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopTwistControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getMopTwistControlProperties() async throws -> VTMopTwistControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mopTwistControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMopTwistControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.41 MopExtensionFurnitureLegHandlingControlCapability

    private let mopExtensionFurnitureLegHandlingControlCapabilityPath: String = "MopExtensionFurnitureLegHandlingControlCapability"

    public func getMopExtensionFurnitureLegHandlingIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(mopExtensionFurnitureLegHandlingControlCapabilityPath)
        let request = VTRequest<VTMopExtensionFurnitureLegHandlingControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableMopExtensionFurnitureLegHandling() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopExtensionFurnitureLegHandlingControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopExtensionFurnitureLegHandlingControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableMopExtensionFurnitureLegHandling() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopExtensionFurnitureLegHandlingControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopExtensionFurnitureLegHandlingControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getMopExtensionFurnitureLegHandlingControlProperties() async throws -> VTMopExtensionFurnitureLegHandlingControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mopExtensionFurnitureLegHandlingControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMopExtensionFurnitureLegHandlingControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.42 MopDockMopAutoDryingControlCapability

    private let mopDockMopAutoDryingControlCapabilityPath: String = "MopDockMopAutoDryingControlCapability"

    public func getMopDockMopAutoDryingIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopAutoDryingControlCapabilityPath)
        let request = VTRequest<VTMopDockMopAutoDryingControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableMopDockMopAutoDrying() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopAutoDryingControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopDockMopAutoDryingControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableMopDockMopAutoDrying() async throws {
        let url = capabilitiesURL.appendingPathComponent(mopDockMopAutoDryingControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTMopDockMopAutoDryingControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getMopDockMopAutoDryingControlProperties() async throws -> VTMopDockMopAutoDryingControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(mopDockMopAutoDryingControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTMopDockMopAutoDryingControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.43 FloorMaterialDirectionAwareNavigationControlCapability

    private let floorMaterialDirectionAwareNavigationControlCapabilityPath: String = "FloorMaterialDirectionAwareNavigationControlCapability"

    public func getFloorMaterialDirectionAwareNavigationIsEnabled() async throws -> Bool {
        let url = capabilitiesURL.appendingPathComponent(floorMaterialDirectionAwareNavigationControlCapabilityPath)
        let request = VTRequest<VTFloorMaterialDirectionAwareNavigationControlCapabilityState>(method: .GET, url: url)
        return try await send(request).enabled
    }

    public func enableFloorMaterialDirectionAwareNavigation() async throws {
        let url = capabilitiesURL.appendingPathComponent(floorMaterialDirectionAwareNavigationControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTFloorMaterialDirectionAwareNavigationControlCapabilityAction(action: .enable))
        try await send(request)
    }

    public func disableFloorMaterialDirectionAwareNavigation() async throws {
        let url = capabilitiesURL.appendingPathComponent(floorMaterialDirectionAwareNavigationControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTFloorMaterialDirectionAwareNavigationControlCapabilityAction(action: .disable))
        try await send(request)
    }

    public func getFloorMaterialDirectionAwareNavigationControlProperties() async throws -> VTFloorMaterialDirectionAwareNavigationControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(floorMaterialDirectionAwareNavigationControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTFloorMaterialDirectionAwareNavigationControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.44 SpeakerTestCapability

    private let speakerTestCapabilityPath: String = "SpeakerTestCapability"

    public func playSpeakerTestSound() async throws {
        let url = capabilitiesURL.appendingPathComponent(speakerTestCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTSpeakerTestAction(action: .playTestSound))
        try await send(request)
    }

    public func getSpeakerTestCapabilityProperties() async throws -> VTSpeakerTestCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(speakerTestCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTSpeakerTestCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.45 SpeakerVolumeControlCapability

    private let speakerVolumeControlCapabilityPath: String = "SpeakerVolumeControlCapability"

    public func getSpeakerVolume() async throws -> Int {
        let url = capabilitiesURL.appendingPathComponent(speakerVolumeControlCapabilityPath)
        let request = VTRequest<VTSpeakerVolumeState>(method: .GET, url: url)
        return try await send(request).volume
    }

    public func setSpeakerVolume(_ volume: Int) async throws {
        let url = capabilitiesURL.appendingPathComponent(speakerVolumeControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTSpeakerVolumeControlAction(action: .setVolume, value: volume))
        try await send(request)
    }

    public func getSpeakerVolumeControlProperties() async throws -> VTSpeakerVolumeControlCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(speakerVolumeControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTSpeakerVolumeControlCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.46 TotalStatisticsCapability

    public func getTotalStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        let url = capabilitiesURL.appendingPathComponent("TotalStatisticsCapability")
        let request = VTRequest<[VTValetudoDataPoint]>(method: .GET, url: url)
        return try await send(request)
    }

    public func getTotalStatisticsCapabilityProperties() async throws -> VTStatisticsCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent("TotalStatisticsCapability")
            .appendingPathComponent("properties")
        let request = VTRequest<VTStatisticsCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.47 VoicePackManagementCapability

    private let voicePackManagementCapabilityPath: String = "VoicePackManagementCapability"

    public func getVoicePackManagementStatus() async throws -> VTVoicePackManagementStatus {
        let url = capabilitiesURL.appendingPathComponent(voicePackManagementCapabilityPath)
        let request = VTRequest<VTVoicePackManagementStatus>(method: .GET, url: url)
        return try await send(request)
    }

    public func downloadVoicePack(url: String, language: String, hash: String) async throws {
        let endpoint = capabilitiesURL.appendingPathComponent(voicePackManagementCapabilityPath)
        let body = VTVoicePackManagementAction(action: .download, url: url, language: language, hash: hash)
        let request = VTRequest<Void>(method: .PUT, url: endpoint, body: body)
        try await send(request)
    }

    public func getVoicePackManagementCapabilityProperties() async throws -> VTVoicePackManagementCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(voicePackManagementCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTVoicePackManagementCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.48 WifiConfigurationCapability

    private let wifiConfigurationCapabilityPath: String = "WifiConfigurationCapability"

    public func getWifiConfiguration() async throws -> VTWifiConfiguration {
        let url = capabilitiesURL.appendingPathComponent(wifiConfigurationCapabilityPath)
        let request = VTRequest<VTWifiConfiguration>(method: .GET, url: url)
        return try await send(request)
    }

    public func setWifiConfiguration(_ configuration: VTWifiConfigurationAction) async throws {
        let url = capabilitiesURL.appendingPathComponent(wifiConfigurationCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: configuration)
        try await send(request)
    }

    public func getWifiConfigurationCapabilityProperties() async throws -> VTWifiConfigurationCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(wifiConfigurationCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTWifiConfigurationCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.49 WifiScanCapability

    private let wifiScanCapabilityPath: String = "WifiScanCapability"

    public func getWifiNetworks() async throws -> [VTWifiScanResult] {
        let url = capabilitiesURL.appendingPathComponent(wifiScanCapabilityPath)
        let request = VTRequest<[VTWifiScanResult]>(method: .GET, url: url)
        return try await send(request)
    }

    public func getWifiScanCapabilityProperties() async throws -> VTWifiScanCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(wifiScanCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTWifiScanCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.2.50 ZoneCleaningCapability

    private let zoneCleaningCapabilityPath: String = "ZoneCleaningCapability"

    public func clean(zones: [VTZoneCleaningZone], iterations: Int) async throws {
        let url = capabilitiesURL.appendingPathComponent(zoneCleaningCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, body: VTZoneCleaningAction(action: .clean, zones: zones, iterations: iterations))
        try await send(request)
    }

    public func getZoneCleaningCapabilityProperties() async throws -> VTZoneCleaningCapabilityProperties {
        let url = capabilitiesURL
            .appendingPathComponent(zoneCleaningCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTZoneCleaningCapabilityProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 1.3 Properties

    public func getRobotProperties() async throws -> VTRobotProperties {
        let url = robotURL.appendingPathComponent("properties")
        let request = VTRequest<VTRobotProperties>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    // MARK: - 2. System

    // MARK: - 2.1. Host

    public func getHostInfo() async throws -> VTHostInfo {
        let url = hostURL.appendingPathComponent("info")
        let request = VTRequest<VTHostInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    // MARK: - 2.2. Runtime

    public func getRuntimeInfo() async throws -> VTRuntimeInfo {
        let url = runtimeURL.appendingPathComponent("info")
        let request = VTRequest<VTRuntimeInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    // MARK: - 3. Valetudo

    public func canReachValetudo() async -> Bool {
        await (try? getBasicValetudoInfo()) != nil
    }

    public func getBasicValetudoInfo() async throws -> VTBasicValetudoInfo {
        let url = valetudoURL
        let request = VTRequest<VTBasicValetudoInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    // MARK: - 3.1 Version

    public func getValetudoVersionInfo() async throws -> VTValetudoVersionInfo {
        let url = valetudoURL.appendingPathComponent("version")
        let request = VTRequest<VTValetudoVersionInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    // MARK: - 3.2 Log

    public func getLogProperties() async throws -> VTLogLevel {
        let url = logURL.appendingPathComponent("level")
        let request = VTRequest<VTLogLevel>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    public func setLogLevel(_ level: String) async throws {
        let url = logURL.appendingPathComponent("level")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTLogLevelAction(level: level))
        try await send(request)
    }

    public func getLog() async throws -> [VTLogEntry] {
        let url = logURL.appendingPathComponent("content")
        let request = VTRequest<String>(method: .GET, url: url, query: nil)
        let urlRequest = try await makeURLRequest(for: request)
        let (data, response) = try await send(urlRequest)
        try validate(response: response, data: data)
        return VTLogParser.parse(data: data)
    }

    // MARK: - 4 Updater

    public func checkForUpdate() async throws {
        let url = updaterURL
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTUpdaterAction(action: .check))
        try await send(request)
    }

    public func downloadUpdate() async throws {
        let url = updaterURL
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTUpdaterAction(action: .download))
        try await send(request)
    }

    public func applyUpdate() async throws {
        let url = updaterURL
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTUpdaterAction(action: .apply))
        try await send(request)
    }

    // MARK: 4.1 State

    public func getUpdaterState() async throws -> any VTUpdaterState {
        let url = updaterURL.appendingPathComponent("state")
        let request = VTRequest<VTUpdaterStateDecoder>(method: .GET, url: url, query: nil)
        return try await send(request).stateObject
    }

    // MARK: 4.2 Config

    public func getUpdaterConfiguration() async throws -> VTUpdaterConfig {
        let url = updaterURL.appendingPathComponent("config")
        let request = VTRequest<VTUpdaterConfig>(method: .GET, url: url, query: nil)
        return try await send(request)
    }

    public func setUpdaterConfiguration(_ config: VTUpdaterConfig) async throws {
        let url = updaterURL.appendingPathComponent("config")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: config)
        try await send(request)
    }

    // MARK: - 5 Timers

    public func getTimers() async throws -> [String: VTTimer] {
        let request = VTRequest<[String: VTTimer]>(method: .GET, url: timersURL)
        return try await send(request)
    }

    public func addTimer(_ timer: VTTimer) async throws {
        let request = VTRequest<Void>(method: .POST, url: timersURL, query: nil, body: timer)
        return try await send(request)
    }

    // MARK: - 5.1 {id}

    public func getTimer(id: String) async throws -> VTTimer {
        let url = timersURL.appendingPathComponent(id)
        let request = VTRequest<VTTimer>(method: .GET, url: url)
        return try await send(request)
    }

    public func updateTimer(_ timer: VTTimer) async throws {
        guard let id: String = timer.id else {
            let domain = String(describing: VTTimer.self)
            throw VTAPIError.missingID(domain)
        }
        let url = timersURL.appendingPathComponent(id)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: timer)
        return try await send(request)
    }

    public func deleteTimer(id: String) async throws {
        let url = timersURL.appendingPathComponent(id)
        let request = VTRequest<Void>(method: .DELETE, url: url)
        try await send(request)
    }

    // MARK: - 5.2 {id}/action

    public func executeTimer(id: String) async throws {
        let url = timersURL.appendingPathComponent(id).appendingPathComponent("action")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTTimerExecutionAction())
        try await send(request)
    }

    // MARK: - 5.3 Properties

    public func getTimerProperties() async throws -> VTTimersProperties {
        let url = timersURL.appendingPathComponent("properties")
        let request = VTRequest<VTTimersProperties>(method: .GET, url: url)
        return try await send(request)
    }

    // MARK: - 6.0 Events

    public func getValetudoEvents() async throws -> [any VTValetudoEvent] {
        let request = VTRequest<[VTAnyValetudoEvent]>(method: .GET, url: eventsURL)
        return try await send(request).map(\.event)
    }

    // MARK: - 6.1 {id}

    public func getValetudoEvent(id: String) async throws -> any VTValetudoEvent {
        let url = eventsURL.appendingPathComponent(id)
        let request = VTRequest<VTAnyValetudoEvent>(method: .GET, url: url)
        return try await send(request).event
    }

    // MARK: - 6.2 {id}/interact

    public func interactWithValetudoEvent(id: String, interaction: VTEventInteraction) async throws {
        let url = eventsURL.appendingPathComponent(id).appendingPathComponent("interact")
        let action = VTEventInteractionAction(interaction: interaction)
        let request = VTRequest<Void>(method: .PUT, url: url, body: action)
        return try await send(request)
    }

    // MARK: - 7 NetworkAdvertisement

    // MARK: - 7.1 properties

    public func getNetworkAdvertisementProperties() async throws -> VTNetworkAdvertisementProperties {
        let url = networkAdvertisementURL.appendingPathComponent("properties")
        let request = VTRequest<VTNetworkAdvertisementProperties>(method: .GET, url: url)
        return try await send(request)
    }

    private func send<T: Decodable>(_ request: VTRequest<T>) async throws -> T {
        try await send(request, decode)
    }

    private func send(_ request: VTRequest<Data>) async throws -> Data {
        try await send(request) { data in data }
    }

    private func send(_ request: VTRequest<Void>) async throws {
        try await send(request) { _ in () }
    }

    private func makeRequest(
        url: URL,
        method: String,
        contentType: String,
        accept: String,
        body: Encodable?
    ) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method

        if let body {
            let encoded = try encoder.encode(body)
            request.httpBody = encoded
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        request.setValue(accept, forHTTPHeaderField: "Accept")
        return request
    }

    private func send<T>(_ request: VTRequest<T>,
                         _ decode: @escaping (Data) async throws -> T) async throws -> T
    {
        let urlRequest = try await makeURLRequest(for: request)
        let (data, response) = try await send(urlRequest)
        try validate(response: response, data: data)
        return try await decode(data)
    }

    private func makeURLRequest(for request: VTRequest<some Any>) async throws -> URLRequest {
        guard let url = request.url ?? URL(string: "", relativeTo: baseURL) else {
            throw URLError(.badURL)
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let query = request.query {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }

        return try await makeRequest(
            url: finalURL,
            method: request.method.rawValue,
            contentType: request.contentType.rawValue,
            accept: request.accept.rawValue,
            body: request.body
        )
    }

    private func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request, delegate: nil)
    }

    private func decode<T: Decodable>(data: Data) async throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601Flexible
        return try decoder.decode(T.self, from: data)
    }

    private func validate(response: URLResponse, data _: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ..< 300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
}
