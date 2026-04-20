//
//  VTNotificationButton.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation
import UIKit

class VTValetudoEventBarButton: UIBarButtonItem {
    let client: any VTAPIClientProtocol
    private var observerToken: VTListenerToken?
    private var eventCount: Int = 0
    
    init(client: any VTAPIClientProtocol) {
        self.client = client
        super.init()
        self.image = UIImage(systemName: "bell.fill")
        self.target = self
        self.action = #selector(showEventsPopup(_:))
        Task { await startEventObservation() }
    }
    
    required init?(coder: NSCoder) {
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
        vc.title = "EVENTS".localizedCapitalized()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover

        guard let popover = nav.popoverPresentationController else { return }
        popover.barButtonItem = sender
        popover.permittedArrowDirections = .any
        popover.delegate = vc
    
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        
        let topViewController = root.presentedViewController ?? root
        topViewController.present(nav, animated: true)
    }
    
    @MainActor
    private func startEventObservation() async {
        do {
            eventCount = try await client.getValetudoEvents().count
            updateBadge()
        } catch {
            eventCount = 0
            updateBadge()
            log(message: error.localizedDescription, forSubsystem: .event, level: .error)
        }
        
        let (token, stream) = await client.registerEventObserver(for: .valetudoEvent)
        observerToken = token
        
        for await event in stream {
            guard !Task.isCancelled else { break }
            
            switch event {
            case .didReceiveData(let events):
                eventCount = events.count
                updateBadge()
            case .didReceiveError(let message):
                log(message: message, forSubsystem: .event, level: .error)
            default:
                break
            }
        }
    }
    
    private func updateBadge() {
        badge = eventCount > 0 ? .count(eventCount) : nil
    }
}
