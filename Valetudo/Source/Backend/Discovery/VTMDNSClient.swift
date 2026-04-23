//
//  MDNSClient.swift
//  Valetudo
//
//  Created by David Klopp on 21.04.26.
//
import Darwin
import Foundation
import Network



/// Scans the local network for Valetudo robots advertised through Bonjour/mDNS.
///
/// This mirrors the Valetudo Companion discovery path: browse `_valetudo._tcp.`, require the
/// TXT `id` field, and deduplicate robots by that Valetudo-provided ID.
@MainActor
final class VTMDNSClient {
    /// Bonjour service type used by Valetudo's web interface advertisement.
    static let valetudoServiceType = "_valetudo._tcp."

    private let domain: String
    private let serviceType: String
    private let scanTimeout: TimeInterval
    private var browser: NWBrowser?
    private var scanContinuation: AsyncStream<[VTMDNSRobot]>.Continuation?
    private var robots: [String: VTMDNSRobot] = [:]

    /// Creates an mDNS client for browsing Valetudo services.
    ///
    /// - Parameters:
    ///   - serviceType: Bonjour service type to browse. Defaults to Valetudo's `_valetudo._tcp.` service.
    ///   - domain: Bonjour domain to search. Use `local.` for the local network.
    ///   - scanTimeout: Number of seconds used by one-shot scans.
    init(
        serviceType: String = VTMDNSClient.valetudoServiceType,
        domain: String = "local.",
        scanTimeout: TimeInterval = 5.0
    ) {
        self.serviceType = serviceType
        self.domain = domain
        self.scanTimeout = scanTimeout
    }

    deinit {
        browser?.cancel()
        scanContinuation?.finish()
    }

    /// Performs a one-shot scan and returns the robots found before `scanTimeout` expires.
    ///
    /// This is useful for screens that only need a snapshot of currently available robots.
    func scanForRobots() async -> [VTMDNSRobot] {
        var latestRobots: [VTMDNSRobot] = []
        let stream = scanForRobotsStream()
        let timeoutTask = Task { [scanTimeout] in
            try? await Task.sleep(for: .seconds(scanTimeout))
            stopScanning()
        }

        for await robots in stream {
            latestRobots = robots
        }

        timeoutTask.cancel()
        return latestRobots
    }

    /// Starts a continuous scan and emits the sorted list whenever discovered robots change.
    ///
    /// The scan stays active until the stream is cancelled or `stopScanning()` is called.
    func scanForRobotsStream() -> AsyncStream<[VTMDNSRobot]> {
        stopScanning()

        return AsyncStream { continuation in
            scanContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.stopScanning()
                }
            }

            let browser = NWBrowser(
                for: .bonjourWithTXTRecord(type: serviceType, domain: domain),
                using: .tcp
            )
            self.browser = browser

            browser.browseResultsChangedHandler = { [weak self] results, _ in
                Task { @MainActor in
                    await self?.updateRobots(from: results)
                }
            }
            browser.stateUpdateHandler = { [weak self] state in
                if case .failed = state {
                    Task { @MainActor in
                        self?.stopScanning()
                    }
                }
            }
            browser.start(queue: .main)
        }
    }

    /// Stops browsing and clears discovered robots.
    func stopScanning() {
        browser?.cancel()
        browser = nil

        let continuation = scanContinuation
        scanContinuation = nil
        continuation?.finish()

        robots.removeAll()
    }

    private func updateRobots(from results: Set<NWBrowser.Result>) async {
        var discoveredRobots: [String: VTMDNSRobot] = [:]

        for result in results {
            guard let robot = await robot(from: result) else { continue }
            discoveredRobots[robot.id] = robot
        }

        robots = discoveredRobots
        publishRobots()
    }

    /// Builds a robot model from a Bonjour result if it has Valetudo's required TXT `id`.
    private func robot(from result: NWBrowser.Result) async -> VTMDNSRobot? {
        guard case let .service(serviceName, _, _, _) = result.endpoint else { return nil }
        guard case let .bonjour(txtRecordObject) = result.metadata else { return nil }

        let txtRecord = txtRecordObject.dictionary
        guard let id = txtRecord["id"] else { return nil }

        let displayName = txtRecord["name"] ?? serviceName

        return VTMDNSRobot(
            id: id,
            name: displayName,
            serviceName: serviceName,
            manufacturer: txtRecord["manufacturer"],
            model: txtRecord["model"],
            version: txtRecord["version"],
            txtRecord: txtRecord,
            endpoint: result.endpoint
        )
    }

    private func publishRobots() {
        let sortedRobots = robots.values.sorted {
            $0.id.localizedStandardCompare($1.id) == .orderedAscending
        }
        scanContinuation?.yield(sortedRobots)
    }
}

