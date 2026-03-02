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

/// One point for the 12-month line chart (month start date + session count).
struct MonthChartItem: Identifiable {
    let id: String
    let monthStart: Date
    let sessionCount: Int
}

/// One day for chart: session count + duration, steps, calories (for metric selector).
struct DayChartItem: Identifiable {
    let id: String
    let dayStart: Date
    let sessionCount: Int
    let totalDurationSeconds: TimeInterval
    let totalSteps: Int
    let totalCalories: Double
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

    /// Sessions that ended within the last N calendar months.
    func sessionsLast(months: Int) -> [CleaningSession] {
        let cal = Calendar.current
        guard let thisMonthStart = cal.dateInterval(of: .month, for: Date())?.start,
              let start = cal.date(byAdding: .month, value: -months, to: thisMonthStart) else { return [] }
        return sessions.filter { $0.endDate >= start }
    }

    var sessionsLast3Months: [CleaningSession] { sessionsLast(months: 3) }
    var sessionsLast6Months: [CleaningSession] { sessionsLast(months: 6) }

    /// Sessions that ended within the last 12 calendar months (same window as last12MonthsLineItems).
    var sessionsLast12Months: [CleaningSession] { sessionsLast(months: 12) }

    func statsLast(months: Int) -> StatsSummary {
        let list = sessionsLast(months: months)
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    var statsLast3Months: StatsSummary { statsLast(months: 3) }
    var statsLast6Months: StatsSummary { statsLast(months: 6) }

    /// Last 12 months aggregate: total sessions, duration, steps, calories.
    var statsLast12Months: StatsSummary { statsLast(months: 12) }

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

    /// Sessions in the last 2 calendar days (for free-user preview).
    var sessionsLast2Days: [CleaningSession] {
        let cal = Calendar.current
        let now = Date()
        guard let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: now) else { return [] }
        let dayStart = cal.startOfDay(for: twoDaysAgo)
        return sessions.filter { $0.endDate >= dayStart }
    }

    /// Last 2 days aggregate: duration, steps, calories (for free-user preview).
    var statsLast2Days: StatsSummary {
        let list = sessionsLast2Days
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    /// 有整理记录的日期集合（当天 0 点），用于日历标蓝圈与限制仅可选有数据日。
    var dayStartsWithSessions: Set<Date> {
        let cal = Calendar.current
        return Set(sessions.map { cal.startOfDay(for: $0.endDate) })
    }

    /// Stats for a single calendar day (for 2-day preview tap detail).
    func statsForDay(dayStart: Date) -> StatsSummary {
        let cal = Calendar.current
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        let list = sessions.filter { $0.endDate >= dayStart && $0.endDate < dayEnd }
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    /// Stats for a calendar week (week start → week start+7).
    func statsForWeek(weekStart: Date) -> StatsSummary {
        let cal = Calendar.current
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        let list = sessions.filter { $0.endDate >= weekStart && $0.endDate < weekEnd }
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    /// Stats for a calendar month (month start → next month).
    func statsForMonth(monthStart: Date) -> StatsSummary {
        let cal = Calendar.current
        let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        let list = sessions.filter { $0.endDate >= monthStart && $0.endDate < monthEnd }
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    /// Sessions that ended within the last N days (including today). So "近7天" = today + 6 days back.
    func sessionsLast(days: Int) -> [CleaningSession] {
        let cal = Calendar.current
        let now = Date()
        guard let start = cal.date(byAdding: .day, value: -(days - 1), to: now) else { return [] }
        let dayStart = cal.startOfDay(for: start)
        return sessions.filter { $0.endDate >= dayStart }
    }

    func statsLast(days: Int) -> StatsSummary {
        let list = sessionsLast(days: days)
        return StatsSummary(
            count: list.count,
            totalDurationSeconds: list.reduce(0) { $0 + $1.durationSeconds },
            totalSteps: list.reduce(0) { $0 + $1.steps },
            totalCalories: list.reduce(0) { $0 + $1.estimatedCalories }
        )
    }

    /// Last N days: one bar per day (oldest to newest), with count + duration/steps/calories for metric selector.
    func lastDaysChartItems(days: Int) -> [DayChartItem] {
        let cal = Calendar.current
        var items: [DayChartItem] = []
        let now = Date()
        for offset in (0..<days).reversed() {
            guard let dayDate = cal.date(byAdding: .day, value: -offset, to: now) else { continue }
            let dayStart = cal.startOfDay(for: dayDate)
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let list = sessions.filter { $0.endDate >= dayStart && $0.endDate < dayEnd }
            let count = list.count
            let duration = list.reduce(0) { $0 + $1.durationSeconds }
            let steps = list.reduce(0) { $0 + $1.steps }
            let calories = list.reduce(0) { $0 + $1.estimatedCalories }
            items.append(DayChartItem(
                id: "d\(days)_\(offset)",
                dayStart: dayStart,
                sessionCount: count,
                totalDurationSeconds: duration,
                totalSteps: steps,
                totalCalories: calories
            ))
        }
        return items
    }

    /// Last 2 days: for free-user preview chart (yesterday + today).
    var last2DaysChartItems: [DayChartItem] {
        let cal = Calendar.current
        var items: [DayChartItem] = []
        let now = Date()
        for offset in [1, 0] {
            guard let dayDate = cal.date(byAdding: .day, value: -offset, to: now) else { continue }
            let dayStart = cal.startOfDay(for: dayDate)
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let list = sessions.filter { $0.endDate >= dayStart && $0.endDate < dayEnd }
            let count = list.count
            let duration = list.reduce(0) { $0 + $1.durationSeconds }
            let steps = list.reduce(0) { $0 + $1.steps }
            let calories = list.reduce(0) { $0 + $1.estimatedCalories }
            items.append(DayChartItem(
                id: "d\(offset)",
                dayStart: dayStart,
                sessionCount: count,
                totalDurationSeconds: duration,
                totalSteps: steps,
                totalCalories: calories
            ))
        }
        return items
    }

    /// Last N months: month start date and session count for bar chart.
    func lastMonthsChartItems(months: Int) -> [MonthChartItem] {
        let cal = Calendar.current
        var items: [MonthChartItem] = []
        guard let thisMonthStart = cal.dateInterval(of: .month, for: Date())?.start else { return items }
        for offset in (0..<months).reversed() {
            guard let monthStart = cal.date(byAdding: .month, value: -offset, to: thisMonthStart) else { continue }
            let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let count = sessions.filter { $0.endDate >= monthStart && $0.endDate < monthEnd }.count
            items.append(MonthChartItem(
                id: "m\(months)_\(offset)",
                monthStart: monthStart,
                sessionCount: count
            ))
        }
        return items
    }

    var last3MonthsChartItems: [MonthChartItem] { lastMonthsChartItems(months: 3) }
    var last6MonthsChartItems: [MonthChartItem] { lastMonthsChartItems(months: 6) }
    var last12MonthsLineItems: [MonthChartItem] { lastMonthsChartItems(months: 12) }
}
