//
//  VTRobotsListViewController.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import Foundation
import UIKit

final class VTRobotsListViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTRobotsListViewSection, VTRobotsListViewItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTRobotsListViewSection, VTRobotsListViewItem>

    var onSelectRobot: ((VTMDNSRobot) -> Void)?

    private let mdnsClient = VTMDNSClient()
    private var dataSource: DataSource!
    private var scanTask: Task<Void, Never>?
    private var robots: [VTMDNSRobot] = []

    init() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)

        title = "ROBOTS".localized()
        navigationItem.subtitle = "SEARCHING_FOR_ROBOTS".localized()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        scanTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    @MainActor
    override func reconnectAndRefresh() async {
        startScanning()
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.delaysContentTouches = false
    }

    private func configureDataSource() {
        let robotCell = UICollectionView.CellRegistration<UICollectionViewListCell, VTMDNSRobot> { cell, _, robot in
            cell.contentConfiguration = VTRobotCellContentConfiguration(robot: robot)
            cell.accessories = [.disclosureIndicator(displayed: .always)]
            cell.backgroundConfiguration = .listCell()
        }

        let statusCell = UICollectionView.CellRegistration<UICollectionViewListCell, VTRobotsListViewItem> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.textProperties.alignment = .center
            content.textProperties.color = .secondaryLabel
            content.secondaryTextProperties.alignment = .center
            content.secondaryTextProperties.color = .tertiaryLabel

            switch item {
            case .scanning:
                content.image = UIImage(systemName: "dot.radiowaves.left.and.right")
                content.text = "SEARCHING_FOR_ROBOTS".localized()
                //content.secondaryText = "Keep this screen open to discover robots on your local network."
            case .empty:
                content.image = UIImage(systemName: "wifi.slash")
                content.text = "NO_ROBOTS_FOUND".localized()
                content.secondaryText = "MAKE_SURE_ROBOT_IS_ONLINE".localized()
            case .robot:
                break
            }

            cell.contentConfiguration = content
            cell.accessories = []
            cell.backgroundConfiguration = .listCell()
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .robot(robot):
                collectionView.dequeueConfiguredReusableCell(using: robotCell, for: indexPath, item: robot)
            case .scanning, .empty:
                collectionView.dequeueConfiguredReusableCell(using: statusCell, for: indexPath, item: item)
            }
        }
    }

    @MainActor
    private func startScanning() {
        stopScanning()
        robots = []
        applySnapshot(animated: false)

        scanTask = Task { @MainActor [weak self] in
            guard let self else { return }

            var didReceiveRobots = false
            for await robots in mdnsClient.scanForRobotsStream() {
                didReceiveRobots = true
                self.robots = robots
                self.applySnapshot(animated: true)
            }

            if !Task.isCancelled, didReceiveRobots, self.robots.isEmpty {
                self.applySnapshot(animated: true)
            }
        }
    }

    @MainActor
    private func stopScanning() {
        scanTask?.cancel()
        scanTask = nil
        mdnsClient.stopScanning()
    }

    @MainActor
    private func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()

        if robots.isEmpty {
            snapshot.appendSections([.status])
            snapshot.appendItems([scanTask == nil ? .empty : .scanning], toSection: .status)
        } else {
            snapshot.appendSections([.robots])
            snapshot.appendItems(robots.map(VTRobotsListViewItem.robot), toSection: .robots)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath),
              case let .robot(robot) = item else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            
            if let onSelectRobot = self.onSelectRobot {
                onSelectRobot(robot)
                return
            }
            
            guard let url = await robot.getUrl() else {
                self.presentUnableToResolveAlert(for: robot)
                return
            }

            self.presentResolvedURLAlert(url: url, for: robot)
        }
    }

    private func presentResolvedURLAlert(url: URL, for robot: VTMDNSRobot) {
        let alert = UIAlertController(
            title: robot.name,
            message: url.absoluteString,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OPEN".localized(), style: .default) { _ in
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private func presentUnableToResolveAlert(for robot: VTMDNSRobot) {
        let alert = UIAlertController(
            title: robot.name,
            message: "UNABLE_TO_RESOLVE_ROBOT_URL".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}
private struct VTRobotCellContentConfiguration: UIContentConfiguration, Hashable {
    let robot: VTMDNSRobot

    func makeContentView() -> UIView & UIContentView {
        VTRobotCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTRobotCellContentConfiguration {
        self
    }
}

private final class VTRobotCellContentView: UIView, UIContentView {
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "robotic.vacuum.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let serviceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()

    private var currentConfiguration: VTRobotCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? VTRobotCellContentConfiguration else { return }
            currentConfiguration = configuration
            apply(configuration)
        }
    }

    init(configuration: VTRobotCellContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setupViews()
        apply(configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, serviceLabel, idLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.alignment = .fill
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [iconView, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 14
        contentStack.alignment = .top
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func apply(_ configuration: VTRobotCellContentConfiguration) {
        let robot = configuration.robot
        titleLabel.text = robot.name
        subtitleLabel.text = Self.subtitle(for: robot)
        serviceLabel.text = "SERVICE".localized() + ": \(robot.serviceName)"
        idLabel.text = "ID".localized() + " : \(robot.id)"
    }

    private static func subtitle(for robot: VTMDNSRobot) -> String {
        let modelParts = [robot.manufacturer, robot.model]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        let model = modelParts.isEmpty ? "UNKNOWN_MODEL".localized() : modelParts.joined(separator: " ")
        guard let version = robot.version, !version.isEmpty else { return model }
        return "\(model) · " + "VALETUDO".localized() + " \(version)"
    }
}
