import Foundation
import Network

fileprivate enum VTHTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

fileprivate struct VTRequest<Response> {
    var method: VTHTTPMethod
    var url: URL?
    var query: [String: String]?
    var body: Encodable?
}

enum VTAPIError: Error, LocalizedError {
    case clientUnavailable
    case unknown(Error)
    case missingID(String)
    case manualControlStateUnavailable
    
    var errorDescription: String? {
        return switch self {
        case .clientUnavailable: "The API client is not available."
        case .manualControlStateUnavailable: "Could not read the manual control state."
        case .missingID(let domain): "Missing id for \(domain)."
        case .unknown(let error): error.localizedDescription
        }
    }
}

public actor VTAPIClient: VTAPIClientProtocol {
    
    static let shared: VTAPIClient? = {
        // TODO: Make this URL configurable
        guard let robotURL = URL(string: "http://dreame-vacuum-r2228o.fritz.box") else { return nil }
        return VTAPIClient(baseURL: robotURL)
    }()

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

    // MARK: - (SSE) Server side events
    lazy var sseSockets: [String: any VTSSESocketProtocol] = [:]

        
    // MARK: - Requests
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let headers: [String: String] = [:] // Default empty headers. Customize if needed.

    public init(baseURL: URL,
                configuration: URLSessionConfiguration = .default)
    {
        self.baseURL = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("v2")
        self.robotURL = self.baseURL
            .appendingPathComponent("robot")
        self.stateURL = self.robotURL
            .appendingPathComponent("state")
        self.capabilitiesURL = self.robotURL
            .appendingPathComponent("capabilities")
        self.systemURL = self.baseURL
            .appendingPathComponent("system")
        self.hostURL = self.systemURL
            .appendingPathComponent("host")
        self.runtimeURL = self.systemURL
            .appendingPathComponent("runtime")
        self.valetudoURL = self.baseURL
            .appendingPathComponent("valetudo")
        self.updaterURL = self.baseURL
            .appendingPathComponent("updater")
        self.logURL = self.valetudoURL
            .appendingPathComponent("log")
        self.timersURL = self.baseURL
            .appendingPathComponent("timers")
        self.eventsURL = self.baseURL
            .appendingPathComponent("events")
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - 1. Robot
    
    public func getRobotInfo() async throws -> VTRobotInfo {
        let infoRequest = VTRequest<VTRobotInfo>(method: .GET, url: self.robotURL, query: nil, body: nil)
        return try await send(infoRequest)
    }
    
    // MARK: - 1.1 State
    
    // MARK: - 1.1.1 Attributes
    
    public func getStateAttributes() async throws -> VTStateAttributeList {
        let url = self.stateURL.appendingPathComponent("attributes")
        let stateAttributesRequest = VTRequest<VTStateAttributeList>(method: .GET, url: url, query: nil, body: nil)
        return try await send(stateAttributesRequest)
    }
    
    // MARK: - 1.1.2 Map
    
    public func getMap() async throws -> VTMapData {
        let url = self.stateURL.appendingPathComponent("map")
        let mapRequest = VTRequest<VTMapData>(method: .GET, url: url, query: nil, body: nil)
        return try await send(mapRequest)
    }
    
    // MARK: - 1.2 Capabilities
    
    func getCapabilities() async throws -> [VTCapability] {
        let url = self.capabilitiesURL
        let capabilitiesRequest = VTRequest<[VTCapability]>(method: .GET, url: url, query: nil, body: nil)
        return try await send(capabilitiesRequest)
    }
    
    // MARK: - 1.2.1 CurrentStatisticsCapability
    
    public func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        let url = self.capabilitiesURL.appendingPathComponent("CurrentStatisticsCapability")
        let statisticsRequest = VTRequest<[VTValetudoDataPoint]>(method: .GET, url: url, query: nil, body: nil)
        return try await send(statisticsRequest)
    }
    
    // MARK: - 1.2.2 BasicControlCapability
    
    public func start() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("BasicControlCapability")
        let data = VTBasicControlAction(action: .start)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }
    
    public func pause() async throws{
        let url = self.capabilitiesURL.appendingPathComponent("BasicControlCapability")
        let data = VTBasicControlAction(action: .pause)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }
    
    public func stop() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("BasicControlCapability")
        let data = VTBasicControlAction(action: .stop)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }
    
    public func home() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("BasicControlCapability")
        let data = VTBasicControlAction(action: .home)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }
    
    // MARK: - 1.2.3 MapSegmentationCapability
    
    public func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MapSegmentationCapability")
        let data = VTMapSegmentationAction(segmentIDs: segmentIDs, iterations: iterations, customOrder: customOrder)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }

    // MARK: - 1.2.4 AutoEmptyDockManualTriggerCapability
    
    func autoEmptyDock() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("AutoEmptyDockManualTriggerCapability")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTManualTriggerAction())
        try await send(request)
    }
    
    // MARK: - 1.2.5 MopDockCleanManualTriggerCapability
    
    func startMopDockClean() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockCleanManualTriggerCapability")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTToggleStartStopAction(action: .start))
        try await send(request)
    }
    
    func stopMopDockClean() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockCleanManualTriggerCapability")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTToggleStartStopAction(action: .stop))
        try await send(request)
    }
    
    // MARK: - 1.2.6 MopDockDryManualTriggerCapability
    
    func startMopDockDry() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockDryManualTriggerCapability")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTToggleStartStopAction(action: .start))
        try await send(request)
    }
    
    func stopMopDockDry() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockDryManualTriggerCapability")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTToggleStartStopAction(action: .stop))
        try await send(request)
    }
    
    // MARK: - 1.2.7 FanSpeedControlCapability / WaterUsageControlCapability / OperationModeControlCapability
    
    private func capabilityPath(forType type: VTPresetType) -> String {
        switch type {
        case .fanSpeed:         "FanSpeedControlCapability"
        case .waterGrade:       "WaterUsageControlCapability"
        case .operationMode:    "OperationModeControlCapability"
        }
    }
    
    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue] {
        let url = self.capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: type))
            .appendingPathComponent("presets")
        let request = VTRequest<[VTPresetValue]>(method: .GET, url: url, query: nil, body: nil)
        return try await send(request)
    }
    
    func setPreset(_ value: VTPresetValue, forType type: VTPresetType) async throws {
        let data = VTPresetAction(name: value)
        let url = self.capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: type))
            .appendingPathComponent("preset")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: data)
        try await send(request)
    }
    
    // MARK: - 1.2.8 ConsumableMonitoringCapability
    
    private let consumableMonitoringCapabilityPath: String = "ConsumableMonitoringCapability"
    
    func getConsumables() async throws -> [VTConsumableStateAttribute] {
        let url = self.capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
        let request = VTRequest<VTStateAttributeList>(method: .GET, url: url, query: nil)
        return try await send(request).attributes.compactMap {
            $0 as? VTConsumableStateAttribute
        }
    }
    
    func getPropertiesForConsumables() async throws -> [VTConsumableStateAttributeProperties] {
        let url = self.capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTConsumableStateAttributePropertiesList>(method: .GET, url: url, query: nil)
        return try await send(request).availableConsumables
    }
    
    func resetConsumable(type: VTConsumableType) async throws {
        let url = self.capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
            .appendingPathComponent(type.rawValue)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTResetAction())
        try await send(request)
    }
    
    func resetConsumable(type: VTConsumableType, subtype: VTConsumableSubType) async throws {
        let url = self.capabilitiesURL
            .appendingPathComponent(consumableMonitoringCapabilityPath)
            .appendingPathComponent(type.rawValue)
            .appendingPathComponent(subtype.rawValue)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTResetAction())
        try await send(request)
    }
    
    // MARK: - 1.2.9 ManualControlCapability
    
    private let manualControlCapabilityPath: String = "ManualControlCapability"
    
    func getManualControlIsEnabled() async throws -> Bool {
        let url = self.capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let request = VTRequest<VTManualControlState>(method: .GET, url: url, query: nil)
        if let enabled = try await send(request).enabled {
            return enabled
        }
        throw VTAPIError.manualControlStateUnavailable
    }
    
    func getManualControlSupportedMovementDirections() async throws -> [VTMoveDirection] {
        let url = self.capabilitiesURL
            .appendingPathComponent(manualControlCapabilityPath)
            .appendingPathComponent("properties")
        let request = VTRequest<VTManualControlState>(method: .GET, url: url, query: nil)
        if let directions = try await send(request).supportedMovementCommands {
            return directions
        }
        throw VTAPIError.manualControlStateUnavailable
    }
    
    func enableManualControl() async throws {
        let url = self.capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTManualControlAction.enable)
        try await send(request)
    }
    
    func disableManualControl() async throws {
        let url = self.capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTManualControlAction.disable)
        try await send(request)
    }
    
    func manualControlMove(direction: VTMoveDirection) async throws {
        let url = self.capabilitiesURL.appendingPathComponent(manualControlCapabilityPath)
        let action = VTManualControlAction.move(direction: direction)
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }
    
    // MARK: - 1.2.10 ManualControlCapability
    
    private let highResolutionManualControlCapabilityPath: String = "HighResolutionManualControlCapability"
    
    func getHighResolutionManualControlIsEnabled() async throws -> Bool {
        let url = self.capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let request = VTRequest<VTHighResolutionManualControlState>(method: .GET, url: url, query: nil)
        return try await send(request).enabled
    }
    
    func enableHighResolutionManualControl() async throws {
        let url = self.capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let action: VTHighResolutionManualControlAction = .enable
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }
    
    func disableHighResolutionManualControl() async throws {
        let url = self.capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let action: VTHighResolutionManualControlAction = .disable
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }
    
    // angle: +- 180.0 and velocity: +-1.0
    func highResolutionManualControlMove(angle: CGFloat, velocity: CGFloat) async throws {
        let url = self.capabilitiesURL.appendingPathComponent(highResolutionManualControlCapabilityPath)
        let action = VTHighResolutionManualControlAction.move(vector: .init(velocity: velocity, angle: angle))
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: action)
        try await send(request)
    }
    
    // MARK: - 1.3 Properties
    
    func getRobotProperties() async throws -> VTRobotProperties {
        let url = self.robotURL.appendingPathComponent("properties")
        let request = VTRequest<VTRobotProperties>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    // MARK: - 2. System
    
    // MARK: - 2.1. Host
    func getHostInfo() async throws -> VTHostInfo {
        let url = self.hostURL.appendingPathComponent("info")
        let request = VTRequest<VTHostInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    // MARK: - 2.2. Runtime
    func getRuntimeInfo() async throws -> VTRuntimeInfo {
        let url = self.runtimeURL.appendingPathComponent("info")
        let request = VTRequest<VTRuntimeInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    // MARK: - 3. Valetudo
    
    func getBasicValetudoInfo() async throws -> VTBasicValetudoInfo {
        let url = self.valetudoURL
        let request = VTRequest<VTBasicValetudoInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    // MARK: - 3.1 Version
    
    func getValetudoVersionInfo() async throws -> VTValetudoVersionInfo {
        let url = self.valetudoURL.appendingPathComponent("version")
        let request = VTRequest<VTValetudoVersionInfo>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    // MARK: - 3.2 Log
    
    func getLogProperties() async throws -> VTLogLevel {
        let url = self.logURL.appendingPathComponent("level")
        let request = VTRequest<VTLogLevel>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    func setLogLevel(_ level: String) async throws {
        let url = self.logURL.appendingPathComponent("level")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTLogLevelAction(level: level))
        try await send(request)
    }
    
    func getLog() async throws -> [VTLogLine] {
        let url = self.logURL.appendingPathComponent("content")
        let request = VTRequest<String>(method: .GET, url: url, query: nil)
        let urlRequest = try await makeURLRequest(for: request)
        let (data, response) = try await send(urlRequest)
        try validate(response: response, data: data)
        return VTLogParser.parse(data: data)
    }
    
    // MARK: - 4 Updater
    
    func checkForUpdate() async throws {
        let url = self.updaterURL
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTUpdaterAction(action: .check))
        try await send(request)
    }
    
    func downloadUpdate() async throws {
        let url = self.updaterURL
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTUpdaterAction(action: .download))
        try await send(request)
    }
    
    func applyUpdate() async throws {
        let url = self.updaterURL
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: VTUpdaterAction(action: .apply))
        try await send(request)
    }
    
    // MARK: 4.1 State
    
    func getUpdaterState() async throws -> any VTUpdaterState {
        let url = self.updaterURL.appendingPathComponent("state")
        let request = VTRequest<VTUpdaterStateDecoder>(method: .GET, url: url, query: nil)
        return try await send(request).stateObject
    }
    
    // MARK: 4.2 Config
    
    func getUpdaterConfiguration() async throws -> VTUpdaterConfig {
        let url = self.updaterURL.appendingPathComponent("config")
        let request = VTRequest<VTUpdaterConfig>(method: .GET, url: url, query: nil)
        return try await send(request)
    }
    
    func setUpdaterConfiguration(_ config: VTUpdaterConfig) async throws {
        let url = self.updaterURL.appendingPathComponent("config")
        let request = VTRequest<Void>(method: .PUT, url: url, query: nil, body: config)
        try await send(request)
    }
    
    // MARK: - 5 Timers
    
    func getTimers() async throws -> [String: VTTimer] {
        let request = VTRequest<[String: VTTimer]>(method: .GET, url: timersURL)
        return try await send(request)
    }
    
    func addTimer(_ timer: VTTimer) async throws {
        let request = VTRequest<Void>(method: .POST, url: timersURL, query: nil, body: timer)
        return try await send(request)
    }
    
    // MARK: - 5.1 {id}
    
    func getTimer(id: String) async throws -> VTTimer {
        let url = timersURL.appendingPathComponent(id)
        let request = VTRequest<VTTimer>(method: .GET, url: url)
        return try await send(request)
    }
    
    func updateTimer(_ timer: VTTimer) async throws {
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
    
    func getTimerProperties() async throws -> VTTimersProperties {
        let url = timersURL.appendingPathComponent("properties")
        let request = VTRequest<VTTimersProperties>(method: .GET, url: url)
        return try await send(request)
    }
    
    // MARK: - 6.0 Events
    
    func getEvents() async throws -> [any VTEvent] {
        let request = VTRequest<[VTAnyEvent]>(method: .GET, url: eventsURL)
        return try await send(request).map(\.event)
    }
    
    // MARK: - 6.1 {id}
    
    func getEvent(id: String) async throws -> any VTEvent {
        let url = eventsURL.appendingPathComponent(id)
        let request = VTRequest<VTAnyEvent>(method: .GET, url: url)
        return try await send(request).event
    }
    
    // MARK: - 6.2 {id}/interact
    
    func interactWithEvent(id: String, interaction: VTEventInteraction) async throws {
        let url = eventsURL.appendingPathComponent(id).appendingPathComponent("interact")
        let action = VTEventInteractionAction(interaction: interaction)
        let request = VTRequest<Void>(method: .PUT, url: url, body: action)
        return try await send(request)
    }
    
    // MARK: - Internal
    
    private func send<T: Decodable>(_ request: VTRequest<T>) async throws -> T {
        try await send(request, decode)
    }

    private func send(_ request: VTRequest<Void>) async throws -> Void {
        try await send(request, { _ in () })
    }

    private func makeRequest(url: URL, method: String, body: Encodable?) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method

        if let body = body {
            let encoded = try encoder.encode(body)
            request.httpBody = encoded
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func send<T>(_ request: VTRequest<T>,
                         _ decode: @escaping (Data) async throws -> T) async throws -> T {
        let urlRequest = try await makeURLRequest(for: request)
        let (data, response) = try await send(urlRequest)
        try validate(response: response, data: data)
        return try await decode(data)
    }

    private func makeURLRequest<T>(for request: VTRequest<T>) async throws -> URLRequest {
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

        return try await makeRequest(url: finalURL, method: request.method.rawValue, body: request.body)
    }

    private func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request, delegate: nil)
    }

    private func decode<T: Decodable>(data: Data) async throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601Flexible
        return try decoder.decode(T.self, from: data)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
