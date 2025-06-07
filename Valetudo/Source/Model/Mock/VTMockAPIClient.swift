//
//  VTMockAPIClient.swift
//  Valetudo
//
//  Created by David Klopp on 16.05.25.
//

import Foundation
import os.log

public actor VTMockAPIClient: VTAPIClientProtocol {
    
    func getStateAttributes() async throws -> VTStateAttributes {
        let data = jsonStateAttributesDuringCleaning.data(using: .utf8)!
        return try JSONDecoder().decode(VTStateAttributes.self, from: data)
    }
    
    private var i = 0
    
    static var shared: VTMockAPIClient? = VTMockAPIClient()

    public func getMap() async throws -> VTMapData {
        let data = if (i % 2) == 0 {
            jsonMapData.data(using: .utf8)!
        } else {
            jsonMapDataDuringCleaning.data(using: .utf8)!
        }
        i += 1
        return try JSONDecoder().decode(VTMapData.self, from: data)
    }
    
    public func getRobotInfo() async throws -> VTRobotInfo {
        let data = jsonRobotInfo.data(using: .utf8)!
        return try JSONDecoder().decode(VTRobotInfo.self, from: data)
    }
    
    public func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint] {
        let data = jsonCurrentStatisticsCapabilities.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601Flexible
        return try decoder.decode([VTValetudoDataPoint].self, from: data)
    }
    
    public func start() async throws {}
    public func pause() async throws {}
    public func stop() async throws {}
    public func home() async throws {}
    
    public func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws {}
    
    func autoEmptyDock() async throws {}
    
    func startMopDockClean() async throws {}
    func stopMopDockClean() async throws {}
    
    func startMopDockDry() async throws {}
    func stopMopDockDry() async throws {}
    
    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue] {
        switch type {
        case .fanSpeed: [.low, .medium, .high, .max]
        case .operationMode: [.vacuum, .mop, .vacuumAndMop]
        case .waterGrade: [.low, .medium, .high]
        }
    }
    
    func setPreset(_ preset: VTPresetValue, forType type: VTPresetType) async throws { }
}
