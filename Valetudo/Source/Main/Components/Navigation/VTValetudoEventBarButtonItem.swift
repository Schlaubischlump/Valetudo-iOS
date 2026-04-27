//
//  VTNotificationButton.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation
import UIKit

class VTValetudoEventBarButtonItem: UIBarButtonItem {
    private let client: any VTAPIClientProtocol
    private var observerToken: VTListenerToken?
    private weak var parentViewController: UIViewController?

    init(client: any VTAPIClientProtocol, parentViewController: UIViewController) {
        self.client = client
        self.parentViewController = parentViewController
        super.init()
        image = .bellFill
        target = self
        action = #selector(showEventsPopup(_:))
        Task { await startEventObservation() }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let observerToken {
            let client = self.client
            Task { await client.removeEventObserver(token: observerToken, for: .valetudoEvent) }
        }
    }

    @objc func showEventsPopup(_ sender: UIBarButtonItem) {
        let vc = VTValetudoEventsViewController(client: client)
        vc.title = "EVENTS".localized()

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover

        guard let popover = nav.popoverPresentationController else { return }
        popover.barButtonItem = sender
        popover.permittedArrowDirections = .any
        popover.delegate = vc

        let topViewController = parentViewController?.presentedViewController ?? parentViewController
        topViewController?.present(nav, animated: true)
    }

    @MainActor
    private func startEventObservation() async {
        do {
            let eventCount = try await client.getValetudoEvents().count
            updateBadge(eventCount: eventCount)
        } catch {
            updateBadge(eventCount: 0)
            log(message: error.localizedDescription, forSubsystem: .valetudoEvent, level: .error)
        }

        let (token, stream) = await client.registerEventObserver(for: .valetudoEvent)
        observerToken = token

        for await event in stream {
            guard !Task.isCancelled else { break }

            switch event {
            case let .didReceiveData(events):
                updateBadge(eventCount: events.count)
            case let .didReceiveError(message):
                log(message: message, forSubsystem: .valetudoEvent, level: .error)
            default:
                break
            }
        }
    }

    private func updateBadge(eventCount: Int) {
        badge = eventCount > 0 ? .count(eventCount) : nil
    }
}
