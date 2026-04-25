//
//  VTMDNSRobot + Hostname.swift
//  Valetudo
//
//  Created by David Klopp on 24.04.26.
//
import Foundation
import Network

@MainActor
fileprivate final class HostOrIPConnectionResolution {
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

private struct VTNetworkAdvertisementProperties: Decodable {
    let port: Int
    let zeroconfHostname: String
}

extension VTMDNSRobot {
    @MainActor
    func resolveHostOrIpAndPortEndpoint() async -> (host: NWEndpoint.Host, port: NWEndpoint.Port)? {
        await withCheckedContinuation { continuation in
            guard case .service = endpoint else {
                continuation.resume(returning: nil)
                return
            }

            let connection = NWConnection(to: endpoint, using: .tcp)
            let resolution = HostOrIPConnectionResolution(connection: connection, continuation: continuation)

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

    @MainActor
    func resolvedHostnameAndPortEndpoint() async -> (host: NWEndpoint.Host, port: NWEndpoint.Port)? {
        guard let resolvedEndpoint = await resolveHostOrIpAndPortEndpoint() else {
            return nil
        }

        guard let properties = await fetchNetworkAdvertisementProperties(from: resolvedEndpoint) else {
            return nil
        }

        guard let port = NWEndpoint.Port(rawValue: UInt16(properties.port)) else {
            return nil
        }

        return (.name(properties.zeroconfHostname, nil), port)
    }

    private func fetchNetworkAdvertisementProperties(
        from endpoint: (host: NWEndpoint.Host, port: NWEndpoint.Port)
    ) async -> VTNetworkAdvertisementProperties? {
        guard let baseURL = makeBaseURL(from: endpoint.host, port: endpoint.port) else {
            return nil
        }

        guard let url = URL(string: "api/v2/networkadvertisement/properties", relativeTo: baseURL) else {
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return nil
            }

            return try JSONDecoder().decode(VTNetworkAdvertisementProperties.self, from: data)
        } catch {
            return nil
        }
    }

    private func makeBaseURL(from host: NWEndpoint.Host, port: NWEndpoint.Port) -> URL? {
        let isIPv6: Bool = if case .ipv6(_) = host { true } else { false }
        let hostString: String? = switch host {
        case let .name(name, _):
            name
        case let .ipv4(address):
            address.rawValue.ipString(addressFamily: AF_INET, maxLength: INET_ADDRSTRLEN)
        case let .ipv6(address):
            address.rawValue.ipString(addressFamily: AF_INET6, maxLength: INET6_ADDRSTRLEN)
        @unknown default:
            nil
        }

        guard let hostString else { return nil }

        var components = URLComponents()
        components.scheme = "http"
        if isIPv6 {
            components.percentEncodedHost = "[\(hostString)]"
        } else {
            components.host = hostString
        }
        components.port = Int(port.rawValue)
        return components.url
    }
}
