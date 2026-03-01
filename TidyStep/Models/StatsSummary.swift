//
//  StatsSummary.swift
//  TidyStep
//

import Foundation

struct StatsSummary {
    var count: Int
    var totalDurationSeconds: TimeInterval
    var totalSteps: Int
    var totalCalories: Double
}

struct WeekBarItem: Identifiable {
    let id: String
    let weekStart: Date
    let sessionCount: Int
}

extension StorageManager {

    /// Sessions that ended within the current calendar week (locale).
    var sessionsThisWeek: [CleaningSession] {
        let cal = Calendar.current
        let now = Date()
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }
        return sessions.filter { $0.endDate >= weekStart }
    }

    /// Sessions that ended within the current calendar month.
    var sessionsThisMonth: [CleaningSession] {
        let cal = Calendar.current
        let now = Date()
        guard let monthStart = cal.dateInterval(of: .month, for: now)?.start else { return [] }
        return sessions.filter { $0.endDate >= monthStart }
    }

    var statsThisWeek: StatsSummary {
        let list = sessionsThisWeek
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    var statsThisMonth: StatsSummary {
        let list = sessionsThisMonth
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    /// Last 8 weeks: week start date and session count for chart.
    var last8WeeksBarItems: [WeekBarItem] {
        let cal = Calendar.current
        var items: [WeekBarItem] = []
        guard let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start else { return items }
        for offset in (0..<8).reversed() {
            guard let weekStart = cal.date(byAdding: .weekOfYear, value: -offset, to: thisWeekStart) else { continue }
            let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            let count = sessions.filter { $0.endDate >= weekStart && $0.endDate < weekEnd }.count
            items.append(WeekBarItem(
                id: "\(offset)",
                weekStart: weekStart,
                sessionCount: count
            ))
        }
        return items
    }
}
