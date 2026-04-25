//
//  VTMDNSRobot + Hostname.swift
//  Valetudo
//
//  Created by David Klopp on 24.04.26.
//
import Foundation
import Network

/// Wraps a temporary `NWConnection`-based resolution and guarantees the continuation is resumed only once.
@MainActor
fileprivate final class EndpointConnectionResolution {
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

extension VTMDNSRobot {
    /// Resolves the most useful base URL for connecting to a discovered robot.
    ///
    /// Resolution strategy:
    /// 1. Open an `NWConnection` to the Bonjour service to obtain a connectable host/IP + port.
    /// 2. Ask the robot for `/api/v2/networkadvertisement/properties`, which returns the advertised
    ///    `zeroconfHostname` and preferred HTTP port.
    /// 3. Prefer a hostname without the `.local` suffix if that shorter hostname is reachable.
    ///
    /// Why step 3 exists:
    /// Bonjour names like `robot.local` depend on mDNS and often stop working across VPN links,
    /// because the remote network usually does not forward multicast DNS. In some environments the
    /// system resolver can still resolve the bare hostname through search domains, for example by
    /// expanding `robot` to something like `robot.fritz.box`.
    ///
    /// Fallback order:
    /// - reachable hostname without `.local`
    /// - advertised Bonjour hostname from the robot API
    /// - directly resolved host/IP from the original Bonjour service
    @MainActor
    func resolveEndpoint() async -> URL? {
        guard let resolvedEndpoint = await resolveHostOrIpAndPort() else { return nil }

        if let properties = await fetchNetworkAdvertisementProperties(from: resolvedEndpoint),
           let port = NWEndpoint.Port(rawValue: UInt16(properties.port)) {
        
            var hostname = properties.zeroconfHostname
            if hostname.hasSuffix(".local") {
                hostname.removeLast(6)
            }
            
            let shortHostPort: (host: NWEndpoint.Host, port: NWEndpoint.Port) = (.name(hostname, nil), port)
            let otherProperties = await fetchNetworkAdvertisementProperties(from: shortHostPort)
            let isSameRobot = (otherProperties == properties)
                        
            if isSameRobot, let url = getUrl(fromHost: shortHostPort.host, andPort: shortHostPort.port) {
                return url
            }
            
            return getUrl(fromHost: .name(properties.zeroconfHostname, nil), andPort: port)
        }
        
        return getUrl(fromHost: resolvedEndpoint.host, andPort: resolvedEndpoint.port)
    }

    /// Resolves the Bonjour service into a concrete remote endpoint by opening a TCP connection.
    ///
    /// `NWBrowser` gives us a service endpoint, but for the follow-up HTTP request we need a host/IP
    /// and port pair. Once the connection reaches `.ready`, `currentPath.remoteEndpoint` contains
    /// the resolved endpoint chosen by the system resolver.
    @MainActor
    private func resolveHostOrIpAndPort() async -> (host: NWEndpoint.Host, port: NWEndpoint.Port)? {
        await withCheckedContinuation { continuation in
            guard case .service = endpoint else {
                continuation.resume(returning: nil)
                return
            }

            let connection = NWConnection(to: endpoint, using: .tcp)
            let resolution = EndpointConnectionResolution(connection: connection, continuation: continuation)

            connection.stateUpdateHandler = { state in
                Task { @MainActor in
                    switch state {
                    case .ready:
                        guard let remoteEndpoint = connection.currentPath?.remoteEndpoint,
                              case let .hostPort(host, port) = remoteEndpoint
                        else {
                            resolution.resume(with: nil)
                            return
                        }

                        resolution.resume(with: (host, port))
                    case .failed, .cancelled:
                        resolution.resume(with: nil)
                    default:
                        break
                    }
                }
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(5))
                resolution.resume(with: nil)
            }

            connection.start(queue: .main)
        }
    }
    
    /// Fetches the robot's own advertised hostname and port from Valetudo.
    ///
    /// Example response:
    /// `{ "port": 80, "zeroconfHostname": "valetudo-impolitemixednewt.local" }`
    private func fetchNetworkAdvertisementProperties(
        from endpoint: (host: NWEndpoint.Host, port: NWEndpoint.Port)
    ) async -> VTNetworkAdvertisementProperties? {
        guard let baseURL = getUrl(fromHost: endpoint.host, andPort: endpoint.port) else { return nil }
        
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 1.0
        config.timeoutIntervalForResource = 1.0
        let client = makeAPIClient(baseURL: baseURL, configuration: config)
        return try? await client.getNetworkAdvertisementProperties()
    }
    
    /// Builds a plain HTTP base URL from a resolved Network framework host and port.
    ///
    /// Named hosts may contain a trailing dot when they come from DNS, which is valid in DNS but not
    /// useful for the URLs we persist and display, so it is normalized away here.
    /// IPv6 literals need brackets when embedded in a URL authority component.
    private func getUrl(fromHost host: NWEndpoint.Host, andPort port: NWEndpoint.Port) -> URL? {
        let isIPv6: Bool = if case .ipv6(_) = host { true } else { false }
        let hostString: String? = switch host {
        case let .name(name, _):
            name.hasSuffix(".") ? String(name.dropLast()) : name
        case let .ipv4(address):
            address.rawValue.ipString(addressFamily: AF_INET, maxLength: INET_ADDRSTRLEN)
        case let .ipv6(address):
            address.rawValue.ipString(addressFamily: AF_INET6, maxLength: INET6_ADDRSTRLEN)
        @unknown default:
            nil
        }

        guard let hostString else { return nil }
        let authority = isIPv6 ? "[\(hostString)]" : hostString
        return URL(string: "http://\(authority):\(port.rawValue)")
    }
}
