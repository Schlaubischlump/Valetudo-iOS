//
//  VTDuststreamViewController.swift
//  Valetudo
//
//  Created by David Klopp on 31.08.26.
//

import UIKit
import WebKit

@MainActor
final class VTDuststreamViewController: UIViewController {
    let controlPanel: VTManualControlPanelView
    var didDismiss: (() -> Void)?

    private let playerView: VTDuststreamPlayerView
    private var didNotifyDismissal = false

    init(streamURL: URL, dimensions: CGSize, controlPanel: VTManualControlPanelView) {
        self.controlPanel = controlPanel
        playerView = VTDuststreamPlayerView(streamURL: streamURL, dimensions: dimensions)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)

        let closeButton = UIButton(configuration: .glass(), primaryAction: UIAction { [weak self] _ in
            self?.dismissCamera(animated: true)
        })
        closeButton.configuration?.image = UIImage(systemName: "xmark")
        closeButton.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 18, weight: .bold)
        closeButton.accessibilityLabel = "CLOSE".localized()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        view.addSubview(controlPanel)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),

            controlPanel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            controlPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestLandscapeOrientation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        playerView.stop()
        restoreOrientationSupport()
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notifyDismissalIfNeeded()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .landscapeRight
    }

    func dismissCamera(animated: Bool) {
        playerView.stop()
        restoreOrientationSupport()
        dismiss(animated: animated) { [weak self] in
            self?.notifyDismissalIfNeeded()
        }
    }

    private func notifyDismissalIfNeeded() {
        guard !didNotifyDismissal else { return }
        didNotifyDismissal = true
        didDismiss?()
    }

    private func requestLandscapeOrientation() {
        #if !targetEnvironment(macCatalyst)
            VTAppDelegate.orientationOverride = .landscape
            setNeedsUpdateOfSupportedInterfaceOrientations()
            view.window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        #endif
    }

    private func restoreOrientationSupport() {
        #if !targetEnvironment(macCatalyst)
            VTAppDelegate.orientationOverride = nil
            presentingViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            let orientations: UIInterfaceOrientationMask = UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
            view.window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientations))
        #endif
    }
}

@MainActor
final class VTDuststreamPlayerView: UIView {
    private let streamView: VTDuststreamView
    private let statusLabel = UILabel()
    private var hasStreamed = false
    private var started = false

    init(streamURL: URL, dimensions: CGSize) {
        streamView = VTDuststreamView(streamURL: streamURL, dimensions: dimensions)
        super.init(frame: .zero)

        backgroundColor = .black
        clipsToBounds = true

        streamView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(streamView)

        statusLabel.text = "CAMERA_CONNECTING".localized()
        statusLabel.textColor = .white
        statusLabel.font = .preferredFont(forTextStyle: .headline)
        statusLabel.textAlignment = .center
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        statusLabel.layer.cornerRadius = 12
        statusLabel.layer.masksToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            streamView.topAnchor.constraint(equalTo: topAnchor),
            streamView.leadingAnchor.constraint(equalTo: leadingAnchor),
            streamView.trailingAnchor.constraint(equalTo: trailingAnchor),
            streamView.bottomAnchor.constraint(equalTo: bottomAnchor),

            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])

        streamView.didChangeState = { [weak self] state in
            self?.updateStreamState(state)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        guard !started else { return }
        started = true
        hasStreamed = false
        statusLabel.isHidden = false
        statusLabel.text = "CAMERA_CONNECTING".localized()
        streamView.start()
    }

    func stop() {
        guard started else { return }
        started = false
        streamView.stop()
    }

    private func updateStreamState(_ state: String) {
        switch state {
        case "streaming":
            hasStreamed = true
            statusLabel.isHidden = true
        case "reconnecting", "stalled":
            statusLabel.isHidden = hasStreamed
            statusLabel.text = "CAMERA_RECONNECTING".localized()
        case "error", "closed":
            statusLabel.isHidden = hasStreamed
            statusLabel.text = "CAMERA_UNAVAILABLE".localized()
        default:
            statusLabel.isHidden = false
            statusLabel.text = "CAMERA_CONNECTING".localized()
        }
    }
}

@MainActor
private final class VTDuststreamView: UIView, WKNavigationDelegate {
    var didChangeState: ((String) -> Void)?

    private let streamURL: URL
    private let dimensions: CGSize
    private let messageHandler: VTWeakScriptMessageHandler
    private let webView: WKWebView
    private let playerScriptAvailable: Bool
    private var started = false

    init(streamURL: URL, dimensions: CGSize) {
        self.streamURL = streamURL
        self.dimensions = dimensions
        messageHandler = VTWeakScriptMessageHandler()

        let configuration = WKWebViewConfiguration()
        let resourceURL = Bundle.main.url(forResource: "jsmpeg", withExtension: "js", subdirectory: "Duststream")
            ?? Bundle.main.url(forResource: "jsmpeg", withExtension: "js")
        if let resourceURL, let script = try? String(contentsOf: resourceURL, encoding: .utf8) {
            configuration.userContentController.addUserScript(
                WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            )
            playerScriptAvailable = true
        } else {
            playerScriptAvailable = false
        }
        configuration.userContentController.add(messageHandler, name: "streamState")
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init(frame: .zero)

        backgroundColor = .black
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        messageHandler.didReceiveMessage = { [weak self] message in
            guard let state = message.body as? String else { return }
            self?.didChangeState?(state)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        guard !started else { return }
        started = true
        guard playerScriptAvailable else {
            didChangeState?("error")
            return
        }

        var bootstrapComponents = URLComponents(url: streamURL, resolvingAgainstBaseURL: false)
        bootstrapComponents?.path = "/index.html"
        bootstrapComponents?.query = nil
        bootstrapComponents?.fragment = nil
        guard let bootstrapURL = bootstrapComponents?.url else {
            didChangeState?("error")
            return
        }
        webView.load(URLRequest(url: bootstrapURL, cachePolicy: .reloadIgnoringLocalCacheData))
    }

    func stop() {
        guard started else { return }
        started = false
        webView.evaluateJavaScript("window.stopDuststream?.()")
        webView.stopLoading()
    }

    func webView(_: WKWebView, didCommit _: WKNavigation?) {
        guard started else { return }
        webView.evaluateJavaScript(playerJavaScript) { [weak self] _, error in
            if error != nil {
                self?.didChangeState?("error")
            }
        }
    }

    func webView(_: WKWebView, didFail _: WKNavigation?, withError _: any Error) {
        guard started else { return }
        didChangeState?("error")
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation?, withError _: any Error) {
        guard started else { return }
        didChangeState?("error")
    }

    private var playerJavaScript: String {
        let streamURLLiteral = String(
            data: try! JSONEncoder().encode(streamURL.absoluteString),
            encoding: .utf8
        )!

        return """
        (() => {
          window.stopDuststream?.();
          document.open();
          document.write(`
            <head>
              <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
              <style>
                html, body { width: 100%; height: 100%; margin: 0; overflow: hidden; background: #000; }
                body { display: flex; align-items: center; justify-content: center; }
                canvas { width: 100%; height: 100%; display: block; object-fit: contain; }
              </style>
            </head>
            <body><canvas id="video"></canvas></body>`);
          document.close();

          const sendState = state => window.webkit.messageHandlers.streamState.postMessage(state);
          const player = new JSMpeg.Player(\(streamURLLiteral), {
            source: JSMpeg.FetchSource,
            canvas: document.getElementById('video'),
            autoplay: true,
            audio: false,
            pauseWhenHidden: false,
            videoBufferSize: 2 * 1024 * 1024,
            reconnectInterval: 3,
            decodeFirstFrame: false,
            videoWidth: \(Int(dimensions.width)),
            videoHeight: \(Int(dimensions.height)),
            createRenderer: options => new JSMpeg.CRTCompositor(options, {label: 'VALETUDO'}),
            onStreamStateChange: status => sendState(status.state)
          });

          player.updateForStreaming = () => {
            const deadline = performance.now() + 12;
            let decodedFrames = 0;
            while (
              decodedFrames < 3 &&
              performance.now() < deadline &&
              player.video?.decode()
            ) {
              decodedFrames++;
            }
          };
          window.stopDuststream = () => player.destroy();
        })();
        """
    }
}

private final class VTWeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    var didReceiveMessage: ((WKScriptMessage) -> Void)?

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        didReceiveMessage?(message)
    }
}
