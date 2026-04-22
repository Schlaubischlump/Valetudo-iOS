//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 14.09.25.
//
import UIKit

fileprivate let unknownString = "UNKNOWN".localized()

final class VTSystemInformationViewController: VTSystemInformationViewControllerBase {
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
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
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
    
    private func memoryItem(for memory: VTMemory) -> VTSystemInformationItem {
        .segmentedBar(config: .init(
            title: "SYSTEM_MEMORY".localized(),
            bars: [
                [
                    .init(value: memory.system/memory.total,             color: .vtGreen),
                    .init(value: memory.valetudo_current/memory.total,   color: .vtRed),
                    .init(value: memory.real_valetudo_max/memory.total,  color: .vtTurquoise),
                    .init(value: memory.real_free/memory.total,          color: .vtBlue)
                ]
            ],
            legend: [
                .init(color: .vtGreen,     text: "SYSTEM".localized()),
                .init(color: .vtRed,       text: "VALETUDO".localized()),
                .init(color: .vtTurquoise, text: "VALETUDO_MAX".localized()),
                .init(color: .vtBlue,      text: "FREE".localized())
            ])
        )
    }
    
    private func cpuItem(for cpus: [VTCPU]) -> VTSystemInformationItem {
        .segmentedBar(config: .init(
            title: "CPU_USAGE".localized(),
            bars: cpus.map { cpu in
                [
                    .init(value: cpu.usage.user/100, color: .vtGreen),
                    .init(value: cpu.usage.nice/100, color: .vtTurquoise),
                    .init(value: cpu.usage.sys/100,  color: .vtRed),
                    .init(value: cpu.usage.irq/100,  color: .vtPurple),
                    .init(value: cpu.usage.idle/100, color: .vtBlue)
                ]
            },
            legend: [
                .init(color: .vtGreen,     text: "USER".localized()),
                .init(color: .vtTurquoise, text: "NICE".localized()),
                .init(color: .vtRed,       text: "SYS".localized()),
                .init(color: .vtPurple,    text: "IRQ".localized()),
                .init(color: .vtBlue,      text: "IDLE".localized())
            ])
        )
    }
    
    private func reloadSegmentedRows() async {
        let hostInfo = try? await client.getHostInfo()
        let memory = hostInfo?.mem ?? .zero
        let cpus = hostInfo?.cpus ?? []

        // TODO: Stable identifiers without embedding the data would allow us to animate the changes
        
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
                    .keyValuePair(title: "MANUFACTURER".localized(), subtitle: manufacturer),
                    .keyValuePair(title: "MODEL".localized(), subtitle: modelName),
                    .keyValuePair(title: "VALETUDO_IMPLEMENTATION".localized(), subtitle: implementation),
                    .keyValuePair(title: "FIRMWARE".localized(), subtitle: firmwareVersion)
                ], toSection: section)
            case .valetudo:
                snapshot.appendItems([
                    .keyValuePair(title: "RELEASE".localized(), subtitle: release),
                    .keyValuePair(title: "COMMIT".localized(), subtitle: commit),
                    .keyValuePair(title: "EMBEDDED".localized(), subtitle: embedded ? "true" : "false"),
                    .keyValuePair(title: "SYSTEM_ID".localized(), subtitle: systemId)
                ], toSection: section)
            case .host:
                snapshot.appendItems([
                    .keyValuePair(title: "HOSTNAME".localized(), subtitle: hostname),
                    .keyValuePair(title: "ARCH".localized(), subtitle: arch),
                    .keyValuePair(title: "UPTIME".localized(), subtitle: hostUptime),
                    memoryItem(for: memory),
                    cpuItem(for: cpus)
                ], toSection: section)
            case .runtime:
                snapshot.appendItems([
                    .keyValuePair(title: "VALETUDO_UPTIME".localized(), subtitle: valetudoUptime),
                    .keyValuePair(title: "UID".localized(), subtitle: uid),
                    .keyValuePair(title: "GID".localized(), subtitle: gid),
                    .keyValuePair(title: "PID".localized(), subtitle: pid),
                    .keyValuePair(title: "ARGV".localized(), subtitle: argv),
                    .link(title: "DEPENDENCIES".localized(), children: [
                        .main: [
                            .keyValuePair(title: "EXEC_PATH".localized(), subtitle: execPath),
                            .keyValuePair(title: "EXEC_ARGV".localized(), subtitle: execArgv),
                        ],
                        .dependencies: versions.sorted(by: { $0.key < $1.key }).map {
                            .keyValuePair(title: $0, subtitle: $1)
                        }
                    ]),
                    .link(title: "ENVIRONMENT".localized(), children: [
                        .keys: env.sorted(by: { $0.key < $1.key }).map {
                            .keyValuePair(title: $0, subtitle: $1)
                        }
                    ]),
                ], toSection: section)
            default:
                continue
            }
        }
        await dataSource.apply(snapshot, animatingDifferences: animated)
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
}


