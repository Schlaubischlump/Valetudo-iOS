import Foundation
import Network

fileprivate enum VTHTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
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
    
    var errorDescription: String? {
        return switch self {
        case .clientUnavailable: "The API client is not available."
        case .unknown(let error): error.localizedDescription
        }
    }
}

public actor VTAPIClient: NSObject, VTAPIClientProtocol {    
    
    static var shared: VTAPIClient? = {
        guard let robotURL = URL(string: "http://dreame-vacuum-r2228o.fritz.box") else { return nil }
        return VTAPIClient(baseURL: robotURL)
    }()

    // MARK: - URLs
    let baseURL: URL
    let robotURL: URL
    let stateURL: URL
    let capabilitiesURL: URL

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

        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - 1. Robot
    
    public func getRobotInfo() async throws -> VTRobotInfo {
        let infoRequest = VTRequest<VTRobotInfo>(
            method: .GET,
            url: self.robotURL,
            query: nil,
            body: nil
        )
        return try await send(infoRequest)
    }
    
    // MARK: - 1.1 State
    
    // MARK: - 1.1.1 Attributes
    
    public func getStateAttributes() async throws -> VTStateAttributes {
        let stateAttributesRequest = VTRequest<VTStateAttributes>(
            method: .GET,
            url: self.stateURL.appendingPathComponent("attributes"),
            query: nil,
            body: nil
        )
        return try await send(stateAttributesRequest)
    }
    
    // MARK: - 1.1.2 Map
    
    public func getMap() async throws -> VTMapData {
        let mapRequest = VTRequest<VTMapData>(
            method: .GET,
            url: self.stateURL.appendingPathComponent("map"),
            query: nil,
            body: nil
        )
        return try await send(mapRequest)
    }
    
    // MARK: - 1.2 Capabilities
    
    // MARK: - 1.2.1 CurrentStatisticsCapability
    
    public func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        let statisticsRequest = VTRequest<[VTValetudoDataPoint]>(
            method: .GET,
            url: self.capabilitiesURL.appendingPathComponent("CurrentStatisticsCapability"),
            query: nil,
            body: nil
        )
        return try await send(statisticsRequest)
    }
    
    // MARK: - 1.2.2 BasicControlCapability
    
    public func start() async throws {
        try await putBasicControlCapability(action: .start)
    }
    
    public func pause() async throws{
        try await putBasicControlCapability(action: .pause)
    }
    
    public func stop() async throws {
        try await putBasicControlCapability(action: .stop)
    }
    
    public func home() async throws {
        try await putBasicControlCapability(action: .home)
    }
    
    private func putBasicControlCapability(action: VTBasicControlCapabilityActionType) async throws {
        let data = VTBasicControlCapability(action: action)
        let request = VTRequest<Void>(
            method: .PUT,
            url: self.capabilitiesURL.appendingPathComponent("BasicControlCapability"),
            query: nil,
            body: data
        )
        try await send(request)
    }
    
    // MARK: - 1.2.3 MapSegmentationCapability
    
    public func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws {
        let data = VTMapSegmentationCapability(
            segmentIDs: segmentIDs,
            iterations: iterations,
            customOrder: customOrder
        )
        let request = VTRequest<Void>(
            method: .PUT,
            url: self.capabilitiesURL.appendingPathComponent("MapSegmentationCapability"),
            query: nil,
            body: data
        )
        try await send(request)
    }

    // MARK: - 1.2.4 AutoEmptyDockManualTriggerCapability
    
    func autoEmptyDock() async throws {
        let request = VTRequest<Void>(
            method: .PUT,
            url: self.capabilitiesURL.appendingPathComponent("AutoEmptyDockManualTriggerCapability"),
            query: nil,
            body: VTTriggerManualCapability()
        )
        try await send(request)
    }
    
    // MARK: - 1.2.5 MopDockCleanManualTriggerCapability
    
    private func toggleCapability(action: VTToggleManualTriggerCapabilityType, at url: URL) async throws {
        let request = VTRequest<Void>(
            method: .PUT,
            url: url,
            query: nil,
            body: VTToggleManualTriggerCapability(action: action)
        )
        try await send(request)
    }
    
    func startMopDockClean() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockCleanManualTriggerCapability")
        try await toggleCapability(action: .start, at: url)
    }
    
    func stopMopDockClean() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockCleanManualTriggerCapability")
        try await toggleCapability(action: .stop, at: url)
    }
    
    // MARK: - 1.2.6 MopDockDryManualTriggerCapability
    
    func startMopDockDry() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockDryManualTriggerCapability")
        try await toggleCapability(action: .start, at: url)
    }
    
    func stopMopDockDry() async throws {
        let url = self.capabilitiesURL.appendingPathComponent("MopDockDryManualTriggerCapability")
        try await toggleCapability(action: .stop, at: url)
    }
    
    // MARK: - 1.2.7 FanSpeedControlCapability / WaterUsageControlCapability / OperationModeControlCapability
    
    private func capabilityPath(forType type: VTPresetType) -> String {
        switch type {
        case .fanSpeed: "FanSpeedControlCapability"
        case .waterGrade: "WaterUsageControlCapability"
        case .operationMode: "OperationModeControlCapability"
        }
    }
    
    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue] {
        let url = self.capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: type))
            .appendingPathComponent("presets")
        let request = VTRequest<[VTPresetValue]>(
            method: .GET,
            url: url,
            query: nil,
            body: nil
        )
        return try await send(request)
    }
    
    func setPreset(_ value: VTPresetValue, forType type: VTPresetType) async throws {
        let data = VTPresetCapability(name: value)
        let url = self.capabilitiesURL
            .appendingPathComponent(capabilityPath(forType: type))
            .appendingPathComponent("preset")
        let request = VTRequest<Void>(
            method: .PUT,
            url: url,
            query: nil,
            body: data
        )
        try await send(request)
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
