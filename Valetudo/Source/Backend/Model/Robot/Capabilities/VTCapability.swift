//
//  VTCapability.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//
import Foundation

/// Based on: https://github.com/Hypfer/Valetudo/blob/master/backend/lib/core/capabilities/index.js
public enum VTCapability: Equatable, Hashable, Sendable, Decodable {
    case autoEmptyDockAutoEmptyDurationControl
    case autoEmptyDockAutoEmptyIntervalControl
    case autoEmptyDockManualTrigger
    case basicControl
    case cameraLightControl
    case carpetModeControl
    case carpetSensorModeControl
    case cleanRouteControl
    case collisionAvoidantNavigationControl
    case combinedVirtualRestrictions
    case consumableMonitoring
    case currentStatistics
    case doNotDisturb
    case fanSpeedControl
    case floorMaterialDirectionAwareNavigationControl
    case goToLocation
    case highResolutionManualControl
    case keyLock
    case locate
    case manualControl
    case mapReset
    case mapSegmentEdit
    case mapSegmentMaterialControl
    case mapSegmentRename
    case mapSegmentation
    case mapSnapshot
    case mappingPass
    case mopDockCleanManualTrigger
    case mopDockDryManualTrigger
    case mopDockMopAutoDryingControl
    case mopDockMopDryingTimeControl
    case mopDockMopWashTemperatureControl
    case mopExtensionControl
    case mopExtensionFurnitureLegHandlingControl
    case mopTwistControl
    case obstacleAvoidanceControl
    case obstacleImages
    case operationModeControl
    case pendingMapChangeHandling
    case persistentMapControl
    case petObstacleAvoidanceControl
    case presetSelection
    case quirks
    case speakerTest
    case speakerVolumeControl
    case totalStatistics
    case voicePackManagement
    case waterUsageControl
    case wifiConfiguration
    case wifiScan
    case zoneCleaning

    case unknown(String)

    var name: String {
        switch self {
        case .autoEmptyDockAutoEmptyDurationControl: "AutoEmptyDockAutoEmptyDurationControlCapability"
        case .autoEmptyDockAutoEmptyIntervalControl: "AutoEmptyDockAutoEmptyIntervalControlCapability"
        case .autoEmptyDockManualTrigger: "AutoEmptyDockManualTriggerCapability"
        case .basicControl: "BasicControlCapability"
        case .cameraLightControl: "CameraLightControlCapability"
        case .carpetModeControl: "CarpetModeControlCapability"
        case .carpetSensorModeControl: "CarpetSensorModeControlCapability"
        case .cleanRouteControl: "CleanRouteControlCapability"
        case .collisionAvoidantNavigationControl: "CollisionAvoidantNavigationControlCapability"
        case .combinedVirtualRestrictions: "CombinedVirtualRestrictionsCapability"
        case .consumableMonitoring: "ConsumableMonitoringCapability"
        case .currentStatistics: "CurrentStatisticsCapability"
        case .doNotDisturb: "DoNotDisturbCapability"
        case .fanSpeedControl: "FanSpeedControlCapability"
        case .floorMaterialDirectionAwareNavigationControl: "FloorMaterialDirectionAwareNavigationControlCapability"
        case .goToLocation: "GoToLocationCapability"
        case .highResolutionManualControl: "HighResolutionManualControlCapability"
        case .keyLock: "KeyLockCapability"
        case .locate: "LocateCapability"
        case .manualControl: "ManualControlCapability"
        case .mapReset: "MapResetCapability"
        case .mapSegmentEdit: "MapSegmentEditCapability"
        case .mapSegmentMaterialControl: "MapSegmentMaterialControlCapability"
        case .mapSegmentRename: "MapSegmentRenameCapability"
        case .mapSegmentation: "MapSegmentationCapability"
        case .mapSnapshot: "MapSnapshotCapability"
        case .mappingPass: "MappingPassCapability"
        case .mopDockCleanManualTrigger: "MopDockCleanManualTriggerCapability"
        case .mopDockDryManualTrigger: "MopDockDryManualTriggerCapability"
        case .mopDockMopAutoDryingControl: "MopDockMopAutoDryingControlCapability"
        case .mopDockMopDryingTimeControl: "MopDockMopDryingTimeControlCapability"
        case .mopDockMopWashTemperatureControl: "MopDockMopWashTemperatureControlCapability"
        case .mopExtensionControl: "MopExtensionControlCapability"
        case .mopExtensionFurnitureLegHandlingControl: "MopExtensionFurnitureLegHandlingControlCapability"
        case .mopTwistControl: "MopTwistControlCapability"
        case .obstacleAvoidanceControl: "ObstacleAvoidanceControlCapability"
        case .obstacleImages: "ObstacleImagesCapability"
        case .operationModeControl: "OperationModeControlCapability"
        case .pendingMapChangeHandling: "PendingMapChangeHandlingCapability"
        case .persistentMapControl: "PersistentMapControlCapability"
        case .petObstacleAvoidanceControl: "PetObstacleAvoidanceControlCapability"
        case .presetSelection: "PresetSelectionCapability"
        case .quirks: "QuirksCapability"
        case .speakerTest: "SpeakerTestCapability"
        case .speakerVolumeControl: "SpeakerVolumeControlCapability"
        case .totalStatistics: "TotalStatisticsCapability"
        case .voicePackManagement: "VoicePackManagementCapability"
        case .waterUsageControl: "WaterUsageControlCapability"
        case .wifiConfiguration: "WifiConfigurationCapability"
        case .wifiScan: "WifiScanCapability"
        case .zoneCleaning: "ZoneCleaningCapability"
        case let .unknown(str): str
        }
    }

    init(name: String) {
        switch name {
        case "AutoEmptyDockAutoEmptyDurationControlCapability": self = .autoEmptyDockAutoEmptyDurationControl
        case "AutoEmptyDockAutoEmptyIntervalControlCapability": self = .autoEmptyDockAutoEmptyIntervalControl
        case "AutoEmptyDockManualTriggerCapability": self = .autoEmptyDockManualTrigger
        case "BasicControlCapability": self = .basicControl
        case "CameraLightControlCapability": self = .cameraLightControl
        case "CarpetModeControlCapability": self = .carpetModeControl
        case "CarpetSensorModeControlCapability": self = .carpetSensorModeControl
        case "CleanRouteControlCapability": self = .cleanRouteControl
        case "CollisionAvoidantNavigationControlCapability": self = .collisionAvoidantNavigationControl
        case "CombinedVirtualRestrictionsCapability": self = .combinedVirtualRestrictions
        case "ConsumableMonitoringCapability": self = .consumableMonitoring
        case "CurrentStatisticsCapability": self = .currentStatistics
        case "DoNotDisturbCapability": self = .doNotDisturb
        case "FanSpeedControlCapability": self = .fanSpeedControl
        case "FloorMaterialDirectionAwareNavigationControlCapability": self = .floorMaterialDirectionAwareNavigationControl
        case "GoToLocationCapability": self = .goToLocation
        case "HighResolutionManualControlCapability": self = .highResolutionManualControl
        case "KeyLockCapability": self = .keyLock
        case "LocateCapability": self = .locate
        case "ManualControlCapability": self = .manualControl
        case "MapResetCapability": self = .mapReset
        case "MapSegmentEditCapability": self = .mapSegmentEdit
        case "MapSegmentMaterialControlCapability": self = .mapSegmentMaterialControl
        case "MapSegmentRenameCapability": self = .mapSegmentRename
        case "MapSegmentationCapability": self = .mapSegmentation
        case "MapSnapshotCapability": self = .mapSnapshot
        case "MappingPassCapability": self = .mappingPass
        case "MopDockCleanManualTriggerCapability": self = .mopDockCleanManualTrigger
        case "MopDockDryManualTriggerCapability": self = .mopDockDryManualTrigger
        case "MopDockMopAutoDryingControlCapability": self = .mopDockMopAutoDryingControl
        case "MopDockMopDryingTimeControlCapability": self = .mopDockMopDryingTimeControl
        case "MopDockMopWashTemperatureControlCapability": self = .mopDockMopWashTemperatureControl
        case "MopExtensionControlCapability": self = .mopExtensionControl
        case "MopExtensionFurnitureLegHandlingControlCapability": self = .mopExtensionFurnitureLegHandlingControl
        case "MopTwistControlCapability": self = .mopTwistControl
        case "ObstacleAvoidanceControlCapability": self = .obstacleAvoidanceControl
        case "ObstacleImagesCapability": self = .obstacleImages
        case "OperationModeControlCapability": self = .operationModeControl
        case "PendingMapChangeHandlingCapability": self = .pendingMapChangeHandling
        case "PersistentMapControlCapability": self = .persistentMapControl
        case "PetObstacleAvoidanceControlCapability": self = .petObstacleAvoidanceControl
        case "PresetSelectionCapability": self = .presetSelection
        case "QuirksCapability": self = .quirks
        case "SpeakerTestCapability": self = .speakerTest
        case "SpeakerVolumeControlCapability": self = .speakerVolumeControl
        case "TotalStatisticsCapability": self = .totalStatistics
        case "VoicePackManagementCapability": self = .voicePackManagement
        case "WaterUsageControlCapability": self = .waterUsageControl
        case "WifiConfigurationCapability": self = .wifiConfiguration
        case "WifiScanCapability": self = .wifiScan
        case "ZoneCleaningCapability": self = .zoneCleaning
        default: self = .unknown(name)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        self.init(name: name)
    }
}
