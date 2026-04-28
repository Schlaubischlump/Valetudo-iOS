//
//  VTMDNSRobot.swift
//  Valetudo
//
//  Created by David Klopp on 23.04.26.
//
import dnssd
import Foundation
import Network

/// A Valetudo robot discovered through Bonjour/mDNS.
///
/// Valetudo advertises a dedicated `_valetudo._tcp.` Bonjour service. The service TXT
/// record contains a stable `id` plus optional robot metadata such as manufacturer, model,
/// version, and display name.
struct VTMDNSRobot: Identifiable, Hashable {
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

    /// Base HTTP URL for connecting to the robot web interface.
    @MainActor
    func getUrl() async -> URL? {
        // Try to get the hostname based url, e.g. http://my-valetudo-robot:80
        // Note, the URL does not include .local, instead we let the system resolver find the DNS search domain.
        // This allows us to access a robot even trough VPN.
        // As a fallback we are also fine with an IPv4 or IPv6 based result, although this is probably changing on
        // next router reboot.
        await resolveEndpoint()
    }
}
