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
    private var eventObservationTask: Task<Void, Never>?
    private weak var parentViewController: UIViewController?

    init(client: any VTAPIClientProtocol, parentViewController: UIViewController) {
        self.client = client
        self.parentViewController = parentViewController
        super.init()
        title = "EVENTS".localized()
        image = .eventsNavigationItem
        target = self
        action = #selector(showEventsPopup(_:))
        startEventObservation()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        eventObservationTask?.cancel()
    }

    @objc func showEventsPopup(_ sender: UIBarButtonItem) {
        guard let topViewController = parentViewController?.presentedViewController ?? parentViewController,
              let sourceView = topViewController.viewIfLoaded,
              sourceView.window != nil
        else { return }

        let vc = VTValetudoEventsViewController(client: client)
        vc.title = "EVENTS".localized()

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover

        guard let popover = nav.popoverPresentationController else { return }
        popover.barButtonItem = sender
        popover.permittedArrowDirections = .any
        popover.delegate = vc

        topViewController.present(nav, animated: true)
    }

    @MainActor
    private func startEventObservation() {
        let client = client
        eventObservationTask = Task { @MainActor [weak self] in
            do {
                let events = try await client.getValetudoEvents()
                self?.updateBadge(events: events)
            } catch {
                guard !Task.isCancelled else { return }
                self?.updateBadge(events: [])
                log(message: error.localizedDescription, forSubsystem: .valetudoEvent, level: .error)
            }

            guard !Task.isCancelled else { return }
            let (token, stream) = await client.registerEventObserver(for: .valetudoEvent)
            var hasConnectedEventStream = false

            for await event in stream {
                guard !Task.isCancelled else { break }

                switch event {
                case .didConnect:
                    if hasConnectedEventStream {
                        do {
                            let events = try await client.getValetudoEvents()
                            self?.updateBadge(events: events)
                        } catch {
                            guard !Task.isCancelled else { break }
                            self?.updateBadge(events: [])
                            log(message: error.localizedDescription, forSubsystem: .valetudoEvent, level: .error)
                        }
                    } else {
                        hasConnectedEventStream = true
                    }
                case let .didReceiveData(events):
                    self?.updateBadge(events: events)
                case let .didReceiveError(message):
                    log(message: message, forSubsystem: .valetudoEvent, level: .error)
                default:
                    break
                }
            }

            // Registration can finish after cancellation, so the task owns token cleanup.
            await client.removeEventObserver(token: token, for: .valetudoEvent)
        }
    }

    private func updateBadge(events: [any VTValetudoEvent]) {
        let eventCount = events.count(where: { $0.processed == false })
        badge = eventCount > 0 ? .count(eventCount) : nil
    }
}
