//
//  VTLogLineCellView.swift
//  Valetudo
//
//  Created by David Klopp on 05.10.25.
//
import UIKit

final class VTTimerCellView: UIView, UIContentView {
    private var currentConfiguration: VTTimerCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? VTTimerCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    // MARK: - UI

    private let toggle = UISwitch()
    private let titleLabel = UILabel()

    private let weekdaysStack = UIStackView()
    private var weekdayLabels: [UILabel] = []

    private let timeLabel = UILabel()
    private let secondaryTimeLabel = UILabel()

    private let detailsLabel = UILabel()

    // MARK: - Init

    init(configuration: VTTimerCellContentConfiguration) {
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        //backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 16
        clipsToBounds = true

        // Toggle
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        // Title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        let runButton = UIButton(type: .system)
        runButton.setImage(.playFill, for: .normal)
        runButton.tintColor = .systemGreen
        runButton.addTarget(self, action: #selector(run), for: .touchUpInside)

        let headerStack = UIStackView(arrangedSubviews: [
            runButton,
            titleLabel,
            UIView(),
            toggle,
        ])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 14

        // MARK: - Weekdays

        setupWeekdays()

        // Time
        timeLabel.font = .systemFont(ofSize: 28, weight: .bold)
        timeLabel.textColor = .label
        timeLabel.numberOfLines = 1

        secondaryTimeLabel.font = .systemFont(ofSize: 13)
        secondaryTimeLabel.textColor = .secondaryLabel
        secondaryTimeLabel.numberOfLines = 1

        let timeStack = UIStackView(arrangedSubviews: [
            timeLabel,
            secondaryTimeLabel,
        ])
        timeStack.axis = .vertical
        timeStack.spacing = 2

        // Details
        detailsLabel.font = .systemFont(ofSize: 13)
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.numberOfLines = 1

        let weekdaysContainer = UIView()
        weekdaysContainer.addSubview(weekdaysStack)
        weekdaysStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            weekdaysStack.topAnchor.constraint(equalTo: weekdaysContainer.topAnchor),
            weekdaysStack.bottomAnchor.constraint(equalTo: weekdaysContainer.bottomAnchor),
            weekdaysStack.leadingAnchor.constraint(equalTo: weekdaysContainer.leadingAnchor),
        ])

        let separatorLine = UIView()
        separatorLine.backgroundColor = .separator
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

        // Main stack
        let vStack = UIStackView(arrangedSubviews: [
            headerStack,
            separatorLine,
            weekdaysContainer,
            timeStack,
            detailsLabel,
        ])
        vStack.axis = .vertical
        vStack.spacing = 14
        vStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(vStack)

        let hPad = 16.0
        let vPad = 12.0

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: vPad),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: hPad),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -hPad),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vPad),
        ])

        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }

    private func setupWeekdays() {
        weekdaysStack.axis = .horizontal
        weekdaysStack.spacing = 12
        weekdaysStack.alignment = .center
        weekdaysStack.distribution = .fill

        let symbols = Calendar.current.veryShortWeekdaySymbols.shiftedLeft()

        weekdayLabels = symbols.map { symbol in
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12, weight: .semibold)

            label.layer.cornerRadius = 14
            label.clipsToBounds = true

            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.black.cgColor

            label.backgroundColor = .white
            label.textColor = .black

            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 28),
                label.heightAnchor.constraint(equalToConstant: 28),
            ])

            label.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectWeekday(_:)))
            label.addGestureRecognizer(tapGesture)

            return label
        }

        weekdayLabels.forEach { weekdaysStack.addArrangedSubview($0) }
    }

    @objc private func toggleChanged() {
        currentConfiguration.onToggle?(toggle.isOn)
    }

    @objc private func selectWeekday(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let index = weekdayLabels.firstIndex(of: label),
              let weekday = VTWeekday(normalizedIndex: index) else { return }
        currentConfiguration.onSelect?(weekday)
    }

    @objc private func run() {
        currentConfiguration.onRun?()
    }

    // MARK: - Apply

    private func apply(configuration: VTTimerCellContentConfiguration) {
        currentConfiguration = configuration

        toggle.isOn = configuration.isEnabled
        titleLabel.text = configuration.title

        timeLabel.text = configuration.timeText
        secondaryTimeLabel.text = configuration.secondaryTimeText

        detailsLabel.text = configuration.detailsText

        updateWeekdays(activeDays: configuration.activeWeekdays)
    }

    // MARK: - Weekday Update

    private func updateWeekdays(activeDays: [VTWeekday]) {
        // 0 = Monday, ..., 6 = Sunday
        let activeDaysIndices = Set(activeDays.map(\.normalizedIndex))

        for (weekday, label) in weekdayLabels.enumerated() {
            let isActive = activeDaysIndices.contains(weekday)

            if isActive {
                label.backgroundColor = .black
                label.textColor = .white
                label.layer.borderWidth = 0
            } else {
                label.backgroundColor = .white
                label.textColor = .black
                label.layer.borderWidth = 1
                label.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
}
