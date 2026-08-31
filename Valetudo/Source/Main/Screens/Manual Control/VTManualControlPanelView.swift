//
//  VTManualControlPanelView.swift
//  Valetudo
//
//  Created by David Klopp on 31.08.26.
//

import UIKit

enum VTManualControlMode: Int, CaseIterable {
    case joystick
    case keys
    case off

    var title: String {
        switch self {
        case .joystick: "JOYSTICK".localized()
        case .keys: "D_PAD".localized()
        case .off: "OFF".localized()
        }
    }

    var image: UIImage? {
        switch self {
        case .joystick: UIImage(systemName: "circle.grid.cross")
        case .keys: UIImage(systemName: "dpad.fill")
        case .off: UIImage(systemName: "power")
        }
    }
}

struct VTManualControlVector: Equatable {
    let angle: CGFloat
    let velocity: CGFloat

    static let zero = VTManualControlVector(angle: 0, velocity: 0)
}

@MainActor
final class VTManualControlPanelView: UIView {
    var didChangeVector: ((VTManualControlVector) -> Void)?

    private let joystickView = VTJoystickControlView()
    private let keysView = VTDirectionalKeysControlView()
    private let offView = UIStackView()

    init(showsBackground: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        if showsBackground {
            let background = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
            background.translatesAutoresizingMaskIntoConstraints = false
            background.layer.cornerRadius = 22
            background.layer.cornerCurve = .continuous
            background.clipsToBounds = true
            addSubview(background)
            NSLayoutConstraint.activate([
                background.topAnchor.constraint(equalTo: topAnchor),
                background.leadingAnchor.constraint(equalTo: leadingAnchor),
                background.trailingAnchor.constraint(equalTo: trailingAnchor),
                background.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        let offImageView = UIImageView(image: UIImage(systemName: "power"))
        offImageView.preferredSymbolConfiguration = .init(pointSize: 34, weight: .regular)
        offImageView.tintColor = .secondaryLabel

        let offLabel = UILabel()
        offLabel.text = "MANUAL_CONTROLS_OFF".localized()
        offLabel.textColor = .secondaryLabel
        offLabel.font = .preferredFont(forTextStyle: .headline)
        offLabel.textAlignment = .center
        offLabel.numberOfLines = 0

        offView.axis = .vertical
        offView.alignment = .center
        offView.spacing = 12
        offView.addArrangedSubview(offImageView)
        offView.addArrangedSubview(offLabel)
        offView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(joystickView)
        addSubview(keysView)
        addSubview(offView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 260),
            heightAnchor.constraint(equalToConstant: 230),
            joystickView.centerXAnchor.constraint(equalTo: centerXAnchor),
            joystickView.centerYAnchor.constraint(equalTo: centerYAnchor),
            keysView.centerXAnchor.constraint(equalTo: centerXAnchor),
            keysView.centerYAnchor.constraint(equalTo: centerYAnchor),
            offView.centerXAnchor.constraint(equalTo: centerXAnchor),
            offView.centerYAnchor.constraint(equalTo: centerYAnchor),
            offView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            offView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
        ])

        joystickView.didChangeVector = { [weak self] vector in self?.didChangeVector?(vector) }
        keysView.didChangeVector = { [weak self] vector in self?.didChangeVector?(vector) }
        setMode(.off, animated: false)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMode(_ mode: VTManualControlMode, animated: Bool) {
        let updates = {
            self.joystickView.alpha = mode == .joystick ? 1 : 0
            self.keysView.alpha = mode == .keys ? 1 : 0
            self.offView.alpha = mode == .off ? 1 : 0
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }

        joystickView.isUserInteractionEnabled = mode == .joystick
        keysView.isUserInteractionEnabled = mode == .keys
        if mode == .off {
            resetInput(notify: false)
        }
    }

    func setTransitioning(_ transitioning: Bool) {
        isUserInteractionEnabled = !transitioning
    }

    func resetInput(notify: Bool) {
        joystickView.reset(animated: true, notify: notify)
        keysView.reset(notify: notify)
    }
}

@MainActor
final class VTManualControlTabBarController: UITabBarController, UITabBarControllerDelegate {
    var didSelectMode: ((VTManualControlMode) -> Void)?
    var didChangeVector: ((VTManualControlVector) -> Void)?
    var didSelectCamera: (() -> Void)?

    private(set) var controlPanels: [VTManualControlPanelView] = []
    private var modeTabs: [VTManualControlMode: UITab] = [:]
    private let cameraTab: UISearchTab

    init() {
        let cameraContent = UIViewController()
        cameraTab = UISearchTab { _ in cameraContent }
        cameraTab.automaticallyActivatesSearch = false
        cameraTab.title = "CAMERA".localized()
        cameraTab.image = UIImage(systemName: "video.fill")
        cameraTab.isHidden = true

        super.init(nibName: nil, bundle: nil)

        var tabs: [UITab] = []
        for mode in VTManualControlMode.allCases {
            let panel = VTManualControlPanelView()
            panel.setMode(mode, animated: false)
            panel.didChangeVector = { [weak self] vector in self?.didChangeVector?(vector) }
            controlPanels.append(panel)

            let content = UIViewController()
            content.view.backgroundColor = .systemBackground
            content.view.addSubview(panel)
            NSLayoutConstraint.activate([
                panel.centerXAnchor.constraint(equalTo: content.view.safeAreaLayoutGuide.centerXAnchor),
                panel.centerYAnchor.constraint(equalTo: content.view.safeAreaLayoutGuide.centerYAnchor),
            ])

            let tab = UITab(title: mode.title, image: mode.image, identifier: "manual-\(mode.rawValue)") { _ in content }
            tab.preferredPlacement = .fixed
            modeTabs[mode] = tab
            tabs.append(tab)
        }
        #if !targetEnvironment(macCatalyst)
            tabs.append(cameraTab)
        #endif
        self.tabs = tabs
        delegate = self
        selectedTab = modeTabs[.off]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMode(_ mode: VTManualControlMode) {
        selectedTab = modeTabs[mode]
    }

    func setTransitioning(_ transitioning: Bool) {
        for tab in modeTabs.values {
            tab.isEnabled = !transitioning
        }
        for panel in controlPanels {
            panel.setTransitioning(transitioning)
        }
    }

    func setCamera(visible: Bool, enabled: Bool) {
        cameraTab.isHidden = !visible
        cameraTab.isEnabled = enabled
    }

    func tabBarController(_: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
        if tab.identifier == cameraTab.identifier {
            didSelectCamera?()
            return false
        }

        return mode(for: tab) != nil
    }

    func tabBarController(_: UITabBarController, didSelectTab selectedTab: UITab, previousTab: UITab?) {
        if selectedTab.identifier == cameraTab.identifier {
            self.selectedTab = previousTab ?? modeTabs[.off]
            didSelectCamera?()
            return
        }

        guard let mode = mode(for: selectedTab) else { return }
        didSelectMode?(mode)
    }

    private func mode(for tab: UITab) -> VTManualControlMode? {
        modeTabs.first(where: { $0.value.identifier == tab.identifier })?.key
    }
}

@MainActor
private final class VTJoystickControlView: UIView {
    var didChangeVector: ((VTManualControlVector) -> Void)?

    private let knobView = UIView()
    private var knobCenterXConstraint: NSLayoutConstraint!
    private var knobCenterYConstraint: NSLayoutConstraint!
    private let size: CGFloat = 160
    private let vectorEmissionInterval: TimeInterval = 0.1
    private var lastVectorEmissionTime: TimeInterval = -.infinity
    private var pendingVector: VTManualControlVector?
    private var vectorEmissionTimer: Timer?

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.secondarySystemFill.withAlphaComponent(0.85)
        layer.cornerRadius = size / 2

        knobView.translatesAutoresizingMaskIntoConstraints = false
        knobView.backgroundColor = .tintColor
        knobView.layer.cornerRadius = size / 8
        knobView.isUserInteractionEnabled = false
        addSubview(knobView)

        knobCenterXConstraint = knobView.centerXAnchor.constraint(equalTo: centerXAnchor)
        knobCenterYConstraint = knobView.centerYAnchor.constraint(equalTo: centerYAnchor)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalTo: widthAnchor),
            knobView.widthAnchor.constraint(equalToConstant: size / 4),
            knobView.heightAnchor.constraint(equalTo: knobView.widthAnchor),
            knobCenterXConstraint,
            knobCenterYConstraint,
        ])

        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset(animated: Bool, notify: Bool) {
        knobCenterXConstraint.constant = 0
        knobCenterYConstraint.constant = 0
        vectorEmissionTimer?.invalidate()
        vectorEmissionTimer = nil
        pendingVector = nil
        if notify {
            emitVector(.zero, immediately: true)
        }

        guard animated else { return }
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let limit = size / 2
        let rawX = location.x - center.x
        let rawY = location.y - center.y
        let distance = hypot(rawX, rawY)
        let scale = distance > limit ? limit / distance : 1
        let x = rawX * scale
        let y = rawY * scale

        knobCenterXConstraint.constant = x
        knobCenterYConstraint.constant = y

        emitVector(
            VTManualControlVector(
                angle: max(-120, min(120, x / limit * 120)),
                velocity: max(-1, min(1, -y / limit))
            )
        )

        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            reset(animated: true, notify: true)
        }
    }

    private func emitVector(_ vector: VTManualControlVector, immediately: Bool = false) {
        let now = ProcessInfo.processInfo.systemUptime
        if immediately {
            vectorEmissionTimer?.invalidate()
            vectorEmissionTimer = nil
            pendingVector = nil
            lastVectorEmissionTime = now
            didChangeVector?(vector)
            return
        }

        pendingVector = vector
        guard vectorEmissionTimer == nil else { return }

        let delay = max(0, vectorEmissionInterval - (now - lastVectorEmissionTime))
        if delay == 0 {
            flushPendingVector()
            return
        }

        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.flushPendingVector()
            }
        }
        vectorEmissionTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func flushPendingVector() {
        vectorEmissionTimer?.invalidate()
        vectorEmissionTimer = nil
        guard let pendingVector else { return }
        self.pendingVector = nil
        lastVectorEmissionTime = ProcessInfo.processInfo.systemUptime
        didChangeVector?(pendingVector)
    }
}

@MainActor
private final class VTDirectionalKeysControlView: UIView {
    var didChangeVector: ((VTManualControlVector) -> Void)?

    private var buttons: [UIButton] = []

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let up = makeButton(systemName: "arrow.up", vector: .init(angle: 0, velocity: 1))
        let down = makeButton(systemName: "arrow.down", vector: .init(angle: 0, velocity: -1))
        let left = makeButton(systemName: "arrow.counterclockwise", vector: .init(angle: -120, velocity: 0))
        let right = makeButton(systemName: "arrow.clockwise", vector: .init(angle: 120, velocity: 0))

        for button in buttons {
            addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 58),
                button.heightAnchor.constraint(equalTo: button.widthAnchor),
            ])
        }

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 200),
            heightAnchor.constraint(equalToConstant: 190),
            up.centerXAnchor.constraint(equalTo: centerXAnchor),
            up.topAnchor.constraint(equalTo: topAnchor),
            left.leadingAnchor.constraint(equalTo: leadingAnchor),
            left.centerYAnchor.constraint(equalTo: centerYAnchor),
            right.trailingAnchor.constraint(equalTo: trailingAnchor),
            right.centerYAnchor.constraint(equalTo: centerYAnchor),
            down.centerXAnchor.constraint(equalTo: centerXAnchor),
            down.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset(notify: Bool) {
        if notify {
            didChangeVector?(.zero)
        }
    }

    private func makeButton(systemName: String, vector: VTManualControlVector) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.baseForegroundColor = .label
        configuration.cornerStyle = .capsule
        configuration.image = UIImage(systemName: systemName)
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 22, weight: .semibold)

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in self?.didChangeVector?(vector) }, for: .touchDown)
        button.addAction(UIAction { [weak self] _ in self?.didChangeVector?(.zero) }, for: [.touchUpInside, .touchUpOutside, .touchCancel])
        buttons.append(button)
        return button
    }
}
