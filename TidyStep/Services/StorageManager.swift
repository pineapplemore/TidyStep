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
    private let maxHistoryCount = 20

    @Published var sessions: [CleaningSession] = []
    @Published var userWeightKg: Double? = nil
    @Published var reminderEnabled: Bool = true
    @Published var reminderWeekday: Int = 0 // 0 = Sunday
    @Published var reminderHour: Int = 20
    @Published var reminderMinute: Int = 0

    init() {
        loadAll()
    }

    func loadAll() {
        if let data = defaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([CleaningSession].self, from: data) {
            sessions = decoded.sorted { $0.endDate > $1.endDate }
        } else {
            sessions = []
        }
        userWeightKg = defaults.object(forKey: "user_weight_kg") as? Double
        reminderEnabled = defaults.object(forKey: "reminder_enabled") as? Bool ?? true
        reminderWeekday = defaults.integer(forKey: "reminder_weekday")
        if reminderWeekday == 0 && defaults.object(forKey: "reminder_weekday") == nil {
            reminderWeekday = 1 // Sunday = 1 in Calendar
        }
        reminderHour = defaults.object(forKey: "reminder_hour") as? Int ?? 20
        reminderMinute = defaults.object(forKey: "reminder_minute") as? Int ?? 0
    }

    func saveWeight(_ kg: Double?) {
        userWeightKg = kg
        if let kg = kg {
            defaults.set(kg, forKey: "user_weight_kg")
        } else {
            defaults.removeObject(forKey: "user_weight_kg")
        }
    }

    func saveReminder(enabled: Bool, weekday: Int, hour: Int, minute: Int) {
        reminderEnabled = enabled
        reminderWeekday = weekday
        reminderHour = hour
        reminderMinute = minute
        defaults.set(enabled, forKey: "reminder_enabled")
        defaults.set(weekday, forKey: "reminder_weekday")
        defaults.set(hour, forKey: "reminder_hour")
        defaults.set(minute, forKey: "reminder_minute")
    }

    func addSession(_ session: CleaningSession) {
        sessions.insert(session, at: 0)
        if sessions.count > maxHistoryCount {
            sessions = Array(sessions.prefix(maxHistoryCount))
        }
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: historyKey)
        }
    }
}
