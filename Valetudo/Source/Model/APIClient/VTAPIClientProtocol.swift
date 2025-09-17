//
//  VTAPIClientProtocol.swift
//  Valetudo
//
//  Created by David Klopp on 16.05.25.
//

import Foundation

protocol VTAPIClientProtocol: Actor {
    static var shared: Self? { get }
        
    // MARK: - 1. Robot
    
    func getRobotInfo() async throws -> VTRobotInfo
    
    // MARK: - 1.1 State
    
    // MARK: - 1.1.1 Attributes
    
    func getStateAttributes() async throws -> VTStateAttributeList
    
    // MARK: - 1.1.2 Map
    
    func getMap() async throws -> VTMapData
    
    // MARK: - 1.1.3 SSE
    
    // TODO: Can we use an additional flag here to support polling. Than we can monitor everything, even things without SSE
    @discardableResult
    func registerEventObserver<E: Decodable & Equatable>(for endpoint: VTEventEndpoint<E>) async -> (VTListenerToken, AsyncStream<VTEventAction<E>>)

    func removeEventObserver<E: Decodable & Equatable>(token: VTListenerToken, for endpoint: VTEventEndpoint<E>) async
    
    // MARK: - 1.2 Capabilities
    
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
    
    // MARK: - 1.3 Properties
    
    func getRobotProperties() async throws -> VTRobotProperties
    
    // MARK: - 2. System
    
    // MARK: - 2.1. Host
    func getHostInfo() async throws -> VTHostInfo
    
    // MARK: - 2.2. Runtime
    func getRuntimeInfo() async throws -> VTRuntimeInfo

    
    // MARK: - 3. Valetudo
    
    func getBasicValetudoInfo() async throws -> VTBasicValetudoInfo
    
    // MARK: - 3.1 Version
    
    func getValetudoVersionInfo() async throws -> VTValetudoVersionInfo
}
