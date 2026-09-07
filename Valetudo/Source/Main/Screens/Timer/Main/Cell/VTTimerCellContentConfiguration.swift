//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 05.10.25.
//
import UIKit

struct VTTimerCellContentConfiguration: UIContentConfiguration {
    var isEnabled: Bool
    var title: String
    var activeWeekdays: [VTWeekday]
    var timeText: String
    var secondaryTimeText: String
    var detailsText: String

    var onToggle: ((Bool) -> Void)?
    var onSelect: ((VTWeekday) -> Void)?
    var onRun: (() -> Void)?

    func makeContentView() -> UIView & UIContentView {
        VTTimerCellView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }
}

extension [VTWeekday] {
    var shortText: String {
        let symbols = Calendar.current.shortWeekdaySymbols // Sun, Mon, ...

        return sorted { $0.rawValue < $1.rawValue }
            .map { symbols[$0.rawValue] }
            .joined(separator: " ")
    }
}

extension VTTimer {
    var formattedTime: String {
        let schedule = localSchedule()
        guard let displayDate = Date.fromUTC(hour: schedule.hour, minute: schedule.minute) else { return "-" }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = .current
        // The schedule is already converted to local wall-clock time.
        formatter.timeZone = .utc

        return formatter.string(from: displayDate)
    }

    var utcTimeText: String {
        guard let utcDate = Date.fromUTC(hour: hour, minute: minute) else { return "-" }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .utc

        return formatter.string(from: utcDate) + " UTC"
    }

    var detailsText: String {
        let actionText = action.type.description.capitalized
        guard !preActions.isEmpty else { return actionText }
        let pre = "\(preActions.count) " + "PRE_ACTIONS".localized()
        return "\(actionText) • \(pre)"
    }

    func toCellConfiguration() -> VTTimerCellContentConfiguration {
        VTTimerCellContentConfiguration(
            isEnabled: enabled,
            title: label,
            activeWeekdays: localSchedule().weekdays,
            timeText: formattedTime,
            secondaryTimeText: utcTimeText,
            detailsText: detailsText
        )
    }
}
