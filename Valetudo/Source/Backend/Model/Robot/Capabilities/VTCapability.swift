//
//  VTCapability.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//
import Foundation

enum VTCapability: Equatable, Hashable, Sendable, Decodable {
    case wifiConfiguration
    case wifiScan
    case basicControl
    case fanSpeedControl
    case locate
    case mapSegmentation
    case mapSegmentEdit
    case mapSegmentRename
    case mapReset
    case combinedVirtualRestrictions
    case speakerVolumeControl
    case speakerTest
    case pendingMapChangeHandling
    case totalStatistics
    case currentStatistics
    case voicePackManagement
    case manualControl
    case highResolutionManualControl
    case doNotDisturb
    case mappingPass
    case waterUsageControl
    case zoneCleaning
    case consumableMonitoring
    case operationModeControl
    case carpetSensorModeControl
    case obstacleImages
    case carpetModeControl
    case keyLock
    case autoEmptyDockAutoEmptyControl
    case autoEmptyDockManualTrigger
    case mopDockCleanManualTrigger
    case mopDockDryManualTrigger
    case goToLocation
    case obstacleAvoidanceControl
    case petObstacleAvoidanceControl
    case collisionAvoidantNavigationControl
    case autoEmptyDockAutoEmptyIntervalControl
    case quirks
    case unknown(String)
    
    var name: String {
        return switch self {
        case .wifiConfiguration: "WifiConfigurationCapability"
        case .wifiScan: "WifiScanCapability"
        case .basicControl: "BasicControlCapability"
        case .fanSpeedControl: "FanSpeedControlCapability"
        case .locate: "LocateCapability"
        case .mapSegmentation: "MapSegmentationCapability"
        case .mapSegmentEdit: "MapSegmentEditCapability"
        case .mapSegmentRename: "MapSegmentRenameCapability"
        case .mapReset: "MapResetCapability"
        case .combinedVirtualRestrictions: "CombinedVirtualRestrictionsCapability"
        case .speakerVolumeControl: "SpeakerVolumeControlCapability"
        case .speakerTest: "SpeakerTestCapability"
        case .pendingMapChangeHandling: "PendingMapChangeHandlingCapability"
        case .totalStatistics: "TotalStatisticsCapability"
        case .currentStatistics: "CurrentStatisticsCapability"
        case .voicePackManagement: "VoicePackManagementCapability"
        case .manualControl: "ManualControlCapability"
        case .highResolutionManualControl: "HighResolutionManualControlCapability"
        case .doNotDisturb: "DoNotDisturbCapability"
        case .mappingPass: "MappingPassCapability"
        case .waterUsageControl: "WaterUsageControlCapability"
        case .zoneCleaning: "ZoneCleaningCapability"
        case .consumableMonitoring: "ConsumableMonitoringCapability"
        case .operationModeControl: "OperationModeControlCapability"
        case .carpetSensorModeControl: "CarpetSensorModeControlCapability"
        case .obstacleImages: "ObstacleImagesCapability"
        case .carpetModeControl: "CarpetModeControlCapability"
        case .keyLock: "KeyLockCapability"
        case .autoEmptyDockAutoEmptyControl: "AutoEmptyDockAutoEmptyControlCapability"
        case .autoEmptyDockManualTrigger: "AutoEmptyDockManualTriggerCapability"
        case .mopDockCleanManualTrigger: "MopDockCleanManualTriggerCapability"
        case .mopDockDryManualTrigger: "MopDockDryManualTriggerCapability"
        case .goToLocation: "GoToLocationCapability"
        case .obstacleAvoidanceControl: "ObstacleAvoidanceControlCapability"
        case .petObstacleAvoidanceControl: "PetObstacleAvoidanceControlCapability"
        case .collisionAvoidantNavigationControl: "CollisionAvoidantNavigationControlCapability"
        case .autoEmptyDockAutoEmptyIntervalControl: "AutoEmptyDockAutoEmptyIntervalControlCapability"
        case .quirks: "QuirksCapability"
        case .unknown(let str): str
        }
    }
    
    init(name: String) {
        switch name {
        case "WifiConfigurationCapability": self = .wifiConfiguration
        case "WifiScanCapability": self = .wifiScan
        case "BasicControlCapability": self = .basicControl
        case "FanSpeedControlCapability": self = .fanSpeedControl
        case "LocateCapability": self = .locate
        case "MapSegmentationCapability": self = .mapSegmentation
        case "MapSegmentEditCapability": self = .mapSegmentEdit
        case "MapSegmentRenameCapability": self = .mapSegmentRename
        case "MapResetCapability": self = .mapReset
        case "CombinedVirtualRestrictionsCapability": self = .combinedVirtualRestrictions
        case "SpeakerVolumeControlCapability": self = .speakerVolumeControl
        case "SpeakerTestCapability": self = .speakerTest
        case "PendingMapChangeHandlingCapability": self = .pendingMapChangeHandling
        case "TotalStatisticsCapability": self = .totalStatistics
        case "CurrentStatisticsCapability": self = .currentStatistics
        case "VoicePackManagementCapability": self = .voicePackManagement
        case "ManualControlCapability": self = .manualControl
        case "HighResolutionManualControlCapability": self = .highResolutionManualControl
        case "DoNotDisturbCapability": self = .doNotDisturb
        case "MappingPassCapability": self = .mappingPass
        case "WaterUsageControlCapability": self = .waterUsageControl
        case "ZoneCleaningCapability": self = .zoneCleaning
        case "ConsumableMonitoringCapability": self = .consumableMonitoring
        case "OperationModeControlCapability": self = .operationModeControl
        case "CarpetSensorModeControlCapability": self = .carpetSensorModeControl
        case "ObstacleImagesCapability": self = .obstacleImages
        case "CarpetModeControlCapability": self = .carpetModeControl
        case "KeyLockCapability": self = .keyLock
        case "AutoEmptyDockAutoEmptyControlCapability": self = .autoEmptyDockAutoEmptyControl
        case "AutoEmptyDockManualTriggerCapability": self = .autoEmptyDockManualTrigger
        case "MopDockCleanManualTriggerCapability": self = .mopDockCleanManualTrigger
        case "MopDockDryManualTriggerCapability": self = .mopDockDryManualTrigger
        case "GoToLocationCapability": self = .goToLocation
        case "ObstacleAvoidanceControlCapability": self = .obstacleAvoidanceControl
        case "PetObstacleAvoidanceControlCapability": self = .petObstacleAvoidanceControl
        case "CollisionAvoidantNavigationControlCapability": self = .collisionAvoidantNavigationControl
        case "AutoEmptyDockAutoEmptyIntervalControlCapability": self = .autoEmptyDockAutoEmptyIntervalControl
        case "QuirksCapability": self = .quirks
        default: self = .unknown(name)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        self.init(name: name)
    }
}
