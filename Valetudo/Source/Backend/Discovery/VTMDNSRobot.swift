//
//  VTMDNSRobot.swift
//  Valetudo
//
//  Created by David Klopp on 23.04.26.
//
import Foundation
import Network

/// A Valetudo robot discovered through Bonjour/mDNS.
///
/// Valetudo advertises a dedicated `_valetudo._tcp.` Bonjour service. The service TXT
/// record contains a stable `id` plus optional robot metadata such as manufacturer, model,
/// version, and display name.
struct VTMDNSRobot: Identifiable, Hashable, Sendable {
    @MainActor
    private final class EndpointResolution {
        private let connection: NWConnection
        private let continuation: CheckedContinuation<(host: NWEndpoint.Host, port: NWEndpoint.Port)?, Never>
        private var didResume = false
        init(
            connection: NWConnection,
            continuation: CheckedContinuation<(host: NWEndpoint.Host, port: NWEndpoint.Port)?, Never>
        ) {
            self.connection = connection
            self.continuation = continuation
        }

        func resume(with endpoint: (host: NWEndpoint.Host, port: NWEndpoint.Port)?) {
            guard !didResume else { return }
            didResume = true
            connection.cancel()
            continuation.resume(returning: endpoint)
        }
    }

    
    /// Stable robot identifier from the Valetudo Bonjour TXT `id` record.
    let id: String

    /// Human-readable robot name from TXT `name`, falling back to the Bonjour service name.
    let name: String

    /// Bonjour service instance name.
    let serviceName: String

    /// Manufacturer from TXT `manufacturer`, if advertised.
    let manufacturer: String?

    /// Model from TXT `model`, if advertised.
    let model: String?

    /// Valetudo version from TXT `version`, if advertised.
    let version: String?

    /// Decoded TXT record values advertised with the service.
    let txtRecord: [String: String]
    
    let endpoint: NWEndpoint

    @MainActor
    private func resolvedHostPortEndpoint() async -> (host: NWEndpoint.Host, port: NWEndpoint.Port)? {
        await withCheckedContinuation { continuation in
            let connection = NWConnection(to: endpoint, using: .tcp)
            let resolution = EndpointResolution(connection: connection, continuation: continuation)

            connection.stateUpdateHandler = { state in
                Task { @MainActor in
                    switch state {
                    case .ready:
                        if let remoteEndpoint = connection.currentPath?.remoteEndpoint,
                           case let .hostPort(host, port) = remoteEndpoint {
                            resolution.resume(with: (host, port))
                        } else {
                            resolution.resume(with: nil)
                        }
                    case .failed, .cancelled:
                        resolution.resume(with: nil)
                    default:
                        break
                    }
                }
            }
            connection.start(queue: .main)
        }
    }
    
    /// Base HTTP URL for connecting to the robot web interface.
    @MainActor
    func getUrl() async -> URL? {
        guard let resolvedEndpoint = await resolvedHostPortEndpoint() else { return nil }
        
        let isIPv6: Bool = if case .ipv6(_) = resolvedEndpoint.host { true } else { false }
        let host: String? = switch resolvedEndpoint.host {
        case let .name(name, _):
            name
        case let .ipv4(address):
            address.rawValue.ipString(addressFamily: AF_INET, maxLength: INET_ADDRSTRLEN)
        case let .ipv6(address):
            address.rawValue.ipString(addressFamily: AF_INET6, maxLength: INET6_ADDRSTRLEN)
        @unknown default:
            nil
        }

        guard let host else { return nil }

        var components = URLComponents()
        components.scheme = "http"
        if isIPv6 {
            components.percentEncodedHost = "[\(host)]"
        } else {
            components.host = host
        }
        components.port = Int(resolvedEndpoint.port.rawValue)
        return components.url
    }
}
