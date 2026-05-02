//
//  VTCapability.swift
//  Valetudo
//
//  Created by David Klopp on 17.09.25.
//
import Foundation

/// Based on: https://github.com/Hypfer/Valetudo/blob/master/backend/lib/core/capabilities/index.js
/// Valetudo: 2026.02.0
public enum VTCapability: Equatable, Hashable, Sendable, Decodable {
    /// Controls how long auto-emptying runs.
    case autoEmptyDockAutoEmptyDurationControl
    /// Controls whether the dock auto-empties automatically and, on some robots, how often it does so.
    case autoEmptyDockAutoEmptyIntervalControl
    /// Lets the user manually trigger dustbin emptying into the auto-empty dock.
    case autoEmptyDockManualTrigger
    /// Provides the core robot controls: start, pause, stop, and return home.
    case basicControl
    /// Enables or disables a light source used to improve low-light obstacle detection.
    case cameraLightControl
    /// Enables or disables automatic suction boost when driving onto carpet.
    case carpetModeControl
    /// Selects how the robot should behave when it detects carpet during navigation.
    case carpetSensorModeControl
    /// Lets the user choose the cleaning route strategy.
    case cleanRouteControl
    /// Toggles between gentler navigation and a lower risk of missed spots.
    case collisionAvoidantNavigationControl
    /// Allows configuring both virtual walls and restricted zones.
    case combinedVirtualRestrictions
    /// Exposes consumable status and reset operations for maintenance items.
    case consumableMonitoring
    /// Provides statistics for the current or most recent cleanup.
    case currentStatistics
    /// Configures a do-not-disturb timespan with vendor-specific behavior.
    case doNotDisturb
    /// Lets the user adjust the robot's suction power.
    case fanSpeedControl
    /// Aligns cleaning direction with configured or detected floor material.
    case floorMaterialDirectionAwareNavigationControl
    /// Sends the robot to a specific map location where it will stay idle.
    case goToLocation
    /// Offers precise analog-style manual control instead of digital movement steps.
    case highResolutionManualControl
    /// Disables control via the robot's physical buttons.
    case keyLock
    /// Makes the robot play a loud locating sound so it can be found.
    case locate
    /// Lets the user drive the robot manually like an RC vehicle.
    case manualControl
    /// Resets the current map.
    case mapReset
    /// Allows joining and splitting detected map segments.
    case mapSegmentEdit
    /// Configures materials assigned to map segments.
    case mapSegmentMaterialControl
    /// Allows assigning names to detected map segments.
    case mapSegmentRename
    /// Enables cleaning individual detected map segments.
    case mapSegmentation
    /// Lists map snapshots and allows restoring them.
    case mapSnapshot
    /// Starts a dedicated mapping pass on robots that support or require it.
    case mappingPass
    /// Starts and stops mop cleaning in the mop dock.
    case mopDockCleanManualTrigger
    /// Starts and stops mop drying in the mop dock.
    case mopDockDryManualTrigger
    /// Toggles whether the mop dock starts drying automatically after a cleanup.
    case mopDockMopAutoDryingControl
    /// Configures the mop drying duration.
    case mopDockMopDryingTimeControl
    /// Configures the temperature used for mop washing in supported docks.
    case mopDockMopWashTemperatureControl
    /// Enables or disables outward mop extension for better edge cleaning.
    case mopExtensionControl
    /// Extends mop handling so the robot can mop closer to chair and table legs.
    case mopExtensionFurnitureLegHandlingControl
    /// Enables or disables twisting maneuvers to mop closer to walls or under overhangs.
    case mopTwistControl
    /// Enables or disables obstacle avoidance on robots with obstacle detection.
    case obstacleAvoidanceControl
    /// Exposes images of obstacles detected during cleanup.
    case obstacleImages
    /// Chooses whether the robot vacuums, mops, or does both.
    case operationModeControl
    /// Lets the user accept or reject a newly discovered map.
    case pendingMapChangeHandling
    /// Controls whether the robot keeps its map across cleanups.
    case persistentMapControl
    /// Enables or disables special pet-feces-focused obstacle avoidance behavior.
    case petObstacleAvoidanceControl
    /// Exposes preset selection for vendor-defined modes.
    case presetSelection
    /// Exposes vendor-, model-, or firmware-specific tunables that do not fit generic abstractions yet.
    case quirks
    /// Plays a test sound at the currently configured speaker volume.
    case speakerTest
    /// Controls the volume of the robot's integrated speaker.
    case speakerVolumeControl
    /// Provides all-time statistics such as total area, count, or runtime.
    case totalStatistics
    /// Lets the user manage and upload voice packs.
    case voicePackManagement
    /// Configures water output for mopping.
    case waterUsageControl
    /// Shows current Wi-Fi details and allows reconfiguration.
    case wifiConfiguration
    /// Scans for nearby Wi-Fi networks.
    case wifiScan
    /// Lets the user clean one or more user-defined map zones.
    case zoneCleaning

    /// Represents a capability unknown to this version of the app.
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
