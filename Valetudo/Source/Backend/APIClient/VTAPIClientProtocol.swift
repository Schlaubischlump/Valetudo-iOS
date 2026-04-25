//
//  VTAPIClientProtocol.swift
//  Valetudo
//
//  Created by David Klopp on 16.05.25.
//

import Foundation

struct VTLogLine {
    let timestamp: Date
    let level: String
    let message: String
}

public func makeAPIClient<S: VTAPIClient>(baseURL: URL, configuration: URLSessionConfiguration = .default) -> S {
    return VTAPIClient(baseURL: baseURL, configuration: configuration) as! S
}

protocol VTAPIClientProtocol: Actor {
        
    
    // MARK: - 1. Robot
    
    func getRobotInfo() async throws -> VTRobotInfo
    
    // MARK: - 1.1 State
    
    // MARK: - 1.1.1 Attributes
    
    func getStateAttributes() async throws -> VTStateAttributeList
    
    // MARK: - 1.1.2 Map
    
    func getMap() async throws -> VTMapData
    
    // MARK: - 1.1.3 SSE
    
    @discardableResult
    func registerEventObserver<E: Decodable & Equatable, O>(for endpoint: VTEventEndpoint<E, O>) async -> (VTListenerToken, AsyncStream<VTEventAction<O>>)

    func removeEventObserver<E: Decodable & Equatable, O>(token: VTListenerToken, for endpoint: VTEventEndpoint<E, O>) async
    
    // MARK: - 1.2 Capabilities
    
    func getCapabilities() async throws -> [VTCapability]
    
    // MARK: - 1.2.1 CurrentStatisticsCapability
    
    func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint]
    
    // MARK: - 1.2.2 BasicControlCapability
    
    func start() async throws
    func pause() async throws
    func stop() async throws
    func home() async throws
    
    // MARK: - 1.2.3 MapSegmentationCapability
    
    func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws
    
    // MARK: - 1.2.4 AutoEmptyDockManualTriggerCapability
    
    func autoEmptyDock() async throws
    
    // MARK: - 1.2.5 MopDockCleanManualTriggerCapability
    
    func startMopDockClean() async throws
    func stopMopDockClean() async throws
    
    // MARK: - 1.2.6 MopDockDryManualTriggerCapability
    
    func startMopDockDry() async throws
    func stopMopDockDry() async throws
    
    // MARK: - 1.2.7 FanSpeedControlCapability / WaterUsageControlCapability / OperationModeControlCapability
    
    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue]
    func setPreset(_ preset: VTPresetValue, forType type: VTPresetType) async throws
    
    // MARK: - 1.2.8 ConsumableMonitoringCapability
    func getConsumables() async throws -> [VTConsumableStateAttribute]
    func getPropertiesForConsumables() async throws -> [VTConsumableStateAttributeProperties]
    func resetConsumable(type: VTConsumableType) async throws
    func resetConsumable(type: VTConsumableType, subtype: VTConsumableSubType) async throws
    
    // MARK: - 1.2.9 ManualControlCapability
    
    func getManualControlIsEnabled() async throws -> Bool
    func getManualControlSupportedMovementDirections() async throws -> [VTMoveDirection]
    func enableManualControl() async throws
    func disableManualControl() async throws
    func manualControlMove(direction: VTMoveDirection) async throws
    
    // MARK: - 1.2.10 ManualControlCapability
    
    func getHighResolutionManualControlIsEnabled() async throws -> Bool
    func enableHighResolutionManualControl() async throws
    func disableHighResolutionManualControl() async throws
    // angle: +- 180.0 and velocity: +-1.0
    func highResolutionManualControlMove(angle: CGFloat, velocity: CGFloat) async throws
    
    // MARK: - 1.3 Properties
    
    func getRobotProperties() async throws -> VTRobotProperties
    
    // MARK: - 2. System
    
    // MARK: - 2.1. Host
    func getHostInfo() async throws -> VTHostInfo
    
    // MARK: - 2.2. Runtime
    func getRuntimeInfo() async throws -> VTRuntimeInfo

    
    // MARK: - 3. Valetudo
    
    func canReachValetudo() async -> Bool
    func getBasicValetudoInfo() async throws -> VTBasicValetudoInfo
    
    // MARK: - 3.1 Version
    
    func getValetudoVersionInfo() async throws -> VTValetudoVersionInfo
    
    // MARK: - 3.2 Log
    
    func getLogProperties() async throws -> VTLogLevel
    func setLogLevel(_ level: String) async throws
    func getLog() async throws -> [VTLogLine]
    
    // MARK: - 4. Updater
    
    func checkForUpdate() async throws
    
    func downloadUpdate() async throws
    
    func applyUpdate() async throws
    
    // MARK: 4.1 State
    
    func getUpdaterState() async throws -> any VTUpdaterState
    
    // MARK: 4.2 State
    
    func getUpdaterConfiguration() async throws -> VTUpdaterConfig
    
    func setUpdaterConfiguration(_ config: VTUpdaterConfig) async throws
    
    // MARK: 5.0 Timer
    
    func getTimers() async throws -> [String: VTTimer]
    
    func addTimer(_ timer: VTTimer) async throws
        
    // MARK: - 5.1 {id}
    
    func getTimer(id: String) async throws -> VTTimer
    
    func updateTimer(_ timer: VTTimer) async throws
    
    func deleteTimer(id: String) async throws
    
    // MARK: - 5.2 {id}/action
    
    func executeTimer(id: String) async throws
    
    // MARK: - 5.3 Properties
    
    func getTimerProperties() async throws -> VTTimersProperties
    
    // MARK: 6.0 Events

    func getValetudoEvents() async throws -> [any VTValetudoEvent]
    
    // MARK: 6.1 {id}
    
    func getValetudoEvent(id: String) async throws -> any VTValetudoEvent
    
    // MARK: 6.1 {id}/interact
    
    func interactWithValetudoEvent(id: String, interaction: VTEventInteraction) async throws
}
