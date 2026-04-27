//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 14.09.25.
//
import UIKit

private let unknownString = "UNKNOWN".localized()

final class VTSystemInformationViewController: VTSystemInformationViewControllerBase {
    private static let hostMemoryID = "HOST_MEMORY"
    private static let hostCPUId = "HOST_CPU"
    private static let robotManufacturerID = "ROBOT_MANUFACTURER"
    private static let robotModelID = "ROBOT_MODEL"
    private static let robotImplementationID = "ROBOT_IMPLEMENTATION"
    private static let robotFirmwareID = "ROBOT_FIRMWARE"
    private static let valetudoReleaseID = "VALETUDO_RELEASE"
    private static let valetudoCommitID = "VALETUDO_COMMIT"
    private static let valetudoEmbeddedID = "VALETUDO_EMBEDDED"
    private static let valetudoSystemID = "VALETUDO_SYSTEM_ID"
    private static let hostHostnameID = "HOST_HOSTNAME"
    private static let hostArchID = "HOST_ARCH"
    private static let hostUptimeID = "HOST_UPTIME"
    private static let runtimeUptimeID = "RUNTIME_UPTIME"
    private static let runtimeUID = "RUNTIME_UID"
    private static let runtimeGID = "RUNTIME_GID"
    private static let runtimePID = "RUNTIME_PID"
    private static let runtimeArgvID = "RUNTIME_ARGV"
    private static let runtimeDependenciesID = "RUNTIME_DEPENDENCIES"
    private static let runtimeEnvironmentID = "RUNTIME_ENVIRONMENT"
    private static let dependenciesExecPathID = "DEPENDENCIES_EXEC_PATH"
    private static let dependenciesExecArgvID = "DEPENDENCIES_EXEC_ARGV"

    // Timer to reload the system information
    private var pollingTimer: Timer?
    private let pollingInterval: TimeInterval = 5.0

    private let refreshControl = UIRefreshControl()

    private var sections: [VTSystemInformationSection] = [.robot, .valetudo, .host, .runtime]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPolling()
    }

    override func configureCollectionView() {
        super.configureCollectionView()

        configureRefreshControlIfSupported(refreshControl, action: #selector(didPullToRefresh))
    }

    @objc private func didPullToRefresh() {
        Task {
            stopPolling()
            await self.reloadData(animated: true)
            startPolling()
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            Task { await self?.reloadSegmentedRows() }
        }
    }

    override func section(for indexPath: IndexPath) -> VTSystemInformationSection {
        sections[indexPath.section]
    }

    private func memoryItem(for memory: VTMemory) -> VTAnyItem {
        .systemInformationSegmentedBar(Self.hostMemoryID, config: .init(
            title: "SYSTEM_MEMORY".localized(),
            bars: [
                [
                    .init(value: memory.system / memory.total, color: .vtGreen),
                    .init(value: memory.valetudo_current / memory.total, color: .vtRed),
                    .init(value: memory.real_valetudo_max / memory.total, color: .vtTurquoise),
                    .init(value: memory.real_free / memory.total, color: .vtBlue),
                ],
            ],
            legend: [
                .init(color: .vtGreen, text: "SYSTEM".localized()),
                .init(color: .vtRed, text: "VALETUDO".localized()),
                .init(color: .vtTurquoise, text: "VALETUDO_MAX".localized()),
                .init(color: .vtBlue, text: "FREE".localized()),
            ]
        ))
    }

    private func cpuItem(for cpus: [VTCPU]) -> VTAnyItem {
        .systemInformationSegmentedBar(Self.hostCPUId, config: .init(
            title: "CPU_USAGE".localized(),
            bars: cpus.map { cpu in
                [
                    .init(value: cpu.usage.user / 100, color: .vtGreen),
                    .init(value: cpu.usage.nice / 100, color: .vtTurquoise),
                    .init(value: cpu.usage.sys / 100, color: .vtRed),
                    .init(value: cpu.usage.irq / 100, color: .vtPurple),
                    .init(value: cpu.usage.idle / 100, color: .vtBlue),
                ]
            },
            legend: [
                .init(color: .vtGreen, text: "USER".localized()),
                .init(color: .vtTurquoise, text: "NICE".localized()),
                .init(color: .vtRed, text: "SYS".localized()),
                .init(color: .vtPurple, text: "IRQ".localized()),
                .init(color: .vtBlue, text: "IDLE".localized()),
            ]
        ))
    }

    private func reloadSegmentedRows() async {
        let hostInfo = try? await client.getHostInfo()
        let memory = hostInfo?.mem ?? .zero
        let cpus = hostInfo?.cpus ?? []

        var snapshot = dataSource.snapshot()
        // drop memory and cpu item based on their index, since we have no stable identifier for them
        var identifiers = snapshot.itemIdentifiers(inSection: .host).dropLast(2)
        identifiers.append(contentsOf: [memoryItem(for: memory), cpuItem(for: cpus)])
        // add new items at the same position, the rest remains unchanged
        snapshot.deleteSections([.host])
        snapshot.insertSections([.host], beforeSection: .runtime)
        snapshot.appendItems(Array(identifiers), toSection: .host)
        await dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func reloadData(animated: Bool) async {
        let robotInfo = try? await client.getRobotInfo()
        let manufacturer = robotInfo?.manufacturer ?? unknownString
        let modelName = robotInfo?.modelName ?? unknownString
        let implementation = robotInfo?.implementation ?? unknownString

        let robotProperties = try? await client.getRobotProperties()
        let firmwareVersion = robotProperties?.firmwareVersion ?? unknownString

        let basicValetudoInfo = try? await client.getBasicValetudoInfo()
        let embedded = basicValetudoInfo?.embedded ?? false
        let systemId = basicValetudoInfo?.systemId ?? unknownString

        let valetudoVersionInfo = try? await client.getValetudoVersionInfo()
        let release = valetudoVersionInfo?.release ?? unknownString
        let commit = valetudoVersionInfo?.commit ?? unknownString

        let hostInfo = try? await client.getHostInfo()
        let hostname = hostInfo?.hostname ?? unknownString
        let arch = hostInfo?.arch ?? unknownString
        var hostUptime = unknownString
        if let uptimeValue = hostInfo?.uptime {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = [.pad]
            hostUptime = formatter.string(from: DateComponents(second: Int(uptimeValue))) ?? unknownString
        }
        let memory = hostInfo?.mem ?? .zero
        let cpus = hostInfo?.cpus ?? []

        let runtimeInfo = try? await client.getRuntimeInfo()
        var valetudoUptime = unknownString
        if let uptimeValue = runtimeInfo?.uptime {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = [.pad]
            valetudoUptime = formatter.string(from: DateComponents(second: Int(uptimeValue))) ?? unknownString
        }
        let uid = String(runtimeInfo?.uid ?? -1)
        let gid = String(runtimeInfo?.gid ?? -1)
        let pid = String(runtimeInfo?.pid ?? -1)
        let argv = (runtimeInfo?.argv ?? []).reduce("") { $0 + "\($1) " }
        let versions = runtimeInfo?.versions ?? [:]
        let env = runtimeInfo?.env ?? [:]
        let execPath = runtimeInfo?.execPath ?? ""
        let execArgv = (runtimeInfo?.execArgv ?? []).reduce("") { $0 + "\($1) " }

        var snapshot = VTSystemInformationSnapshot()
        for section in sections {
            snapshot.appendSections([section])
            switch section {
            case .robot:
                snapshot.appendItems([
                    .keyValue(Self.robotManufacturerID, title: "MANUFACTURER".localized(), value: manufacturer),
                    .keyValue(Self.robotModelID, title: "MODEL".localized(), value: modelName),
                    .keyValue(Self.robotImplementationID, title: "VALETUDO_IMPLEMENTATION".localized(), value: implementation),
                    .keyValue(Self.robotFirmwareID, title: "FIRMWARE".localized(), value: firmwareVersion),
                ], toSection: section)
            case .valetudo:
                snapshot.appendItems([
                    .keyValue(Self.valetudoReleaseID, title: "RELEASE".localized(), value: release),
                    .keyValue(Self.valetudoCommitID, title: "COMMIT".localized(), value: commit),
                    .keyValue(Self.valetudoEmbeddedID, title: "EMBEDDED".localized(), value: embedded ? "true" : "false"),
                    .keyValue(Self.valetudoSystemID, title: "SYSTEM_ID".localized(), value: systemId),
                ], toSection: section)
            case .host:
                snapshot.appendItems([
                    .keyValue(Self.hostHostnameID, title: "HOSTNAME".localized(), value: hostname),
                    .keyValue(Self.hostArchID, title: "ARCH".localized(), value: arch),
                    .keyValue(Self.hostUptimeID, title: "UPTIME".localized(), value: hostUptime),
                    memoryItem(for: memory),
                    cpuItem(for: cpus),
                ], toSection: section)
            case .runtime:
                snapshot.appendItems([
                    .keyValue(Self.runtimeUptimeID, title: "VALETUDO_UPTIME".localized(), value: valetudoUptime),
                    .keyValue(Self.runtimeUID, title: "UID".localized(), value: uid),
                    .keyValue(Self.runtimeGID, title: "GID".localized(), value: gid),
                    .keyValue(Self.runtimePID, title: "PID".localized(), value: pid),
                    .keyValue(Self.runtimeArgvID, title: "ARGV".localized(), value: argv),
                    .systemInformationLink(Self.runtimeDependenciesID, title: "DEPENDENCIES".localized(), children: [
                        .main: [
                            .keyValue(Self.dependenciesExecPathID, title: "EXEC_PATH".localized(), value: execPath),
                            .keyValue(Self.dependenciesExecArgvID, title: "EXEC_ARGV".localized(), value: execArgv),
                        ],
                        .dependencies: versions.sorted(by: { $0.key < $1.key }).map { key, value in
                            .keyValue("DEPENDENCY_\(key)", title: key, value: value)
                        },
                    ]),
                    .systemInformationLink(Self.runtimeEnvironmentID, title: "ENVIRONMENT".localized(), children: [
                        .keys: env.sorted(by: { $0.key < $1.key }).map { key, value in
                            .keyValue("ENV_\(key)", title: key, value: value)
                        },
                    ]),
                ], toSection: section)
            default:
                continue
            }
        }
        await dataSource.apply(snapshot, animatingDifferences: animated)

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}
