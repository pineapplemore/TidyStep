//
//  StorageManager.swift
//  TidyStep
//

import Foundation
import SwiftUI

final class StorageManager: ObservableObject {
    static let shared = StorageManager()

    private let defaults = UserDefaults.standard
    private let historyKey = "cleaning_session_history"
    /// Retain sessions from the last 1 year only. Safety cap to avoid unbounded growth.
    private let retentionYears = 1
    private let maxHistoryCount = 500

    @Published var sessions: [CleaningSession] = []
    @Published var userWeightKg: Double? = nil
    @Published var reminderEnabled: Bool = true
    /// 0 = weekly (use weekday); 3 = every 3 days; 5 = every 5 days.
    @Published var reminderIntervalDays: Int = 0
    @Published var reminderWeekday: Int = 0
    @Published var reminderHour: Int = 8
    @Published var reminderMinute: Int = 0

    init() {
        loadAll()
    }

    func loadAll() {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -retentionYears, to: Date()) ?? Date()
        if let data = defaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([CleaningSession].self, from: data) {
            sessions = decoded
                .filter { $0.endDate >= oneYearAgo }
                .sorted { $0.endDate > $1.endDate }
            if sessions.count > maxHistoryCount {
                sessions = Array(sessions.prefix(maxHistoryCount))
            }
        } else {
            sessions = []
        }
        userWeightKg = defaults.object(forKey: "user_weight_kg") as? Double
        reminderEnabled = defaults.object(forKey: "reminder_enabled") as? Bool ?? true
        reminderWeekday = defaults.integer(forKey: "reminder_weekday")
        if reminderWeekday == 0 && defaults.object(forKey: "reminder_weekday") == nil {
            reminderWeekday = 1 // Sunday = 1 in Calendar
        }
        reminderHour = defaults.object(forKey: "reminder_hour") as? Int ?? 8
        reminderMinute = defaults.object(forKey: "reminder_minute") as? Int ?? 0
        reminderIntervalDays = defaults.object(forKey: "reminder_interval_days") as? Int ?? 0
        pushWidgetData()
    }

    func saveWeight(_ kg: Double?) {
        userWeightKg = kg
        if let kg = kg {
            defaults.set(kg, forKey: "user_weight_kg")
        } else {
            defaults.removeObject(forKey: "user_weight_kg")
        }
    }

    func saveReminder(enabled: Bool, intervalDays: Int, weekday: Int, hour: Int, minute: Int) {
        reminderEnabled = enabled
        reminderIntervalDays = intervalDays
        reminderWeekday = weekday
        reminderHour = hour
        reminderMinute = minute
        defaults.set(enabled, forKey: "reminder_enabled")
        defaults.set(intervalDays, forKey: "reminder_interval_days")
        defaults.set(weekday, forKey: "reminder_weekday")
        defaults.set(hour, forKey: "reminder_hour")
        defaults.set(minute, forKey: "reminder_minute")
        pushWidgetData()
    }

    func addSession(_ session: CleaningSession) {
        sessions.insert(session, at: 0)
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -retentionYears, to: Date()) ?? Date()
        sessions = sessions.filter { $0.endDate >= oneYearAgo }
        if sessions.count > maxHistoryCount {
            sessions = Array(sessions.prefix(maxHistoryCount))
        }
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: historyKey)
        }
        pushWidgetData()
    }

    private func pushWidgetData() {
        WidgetDataManager.update(
            sessions: sessions,
            reminderEnabled: reminderEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            reminderWeekday: reminderWeekday,
            reminderIntervalDays: reminderIntervalDays
        )
    }
}
