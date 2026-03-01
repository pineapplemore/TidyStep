//
//  WidgetDataManager.swift
//  TidyStep
//
//  Writes summary data for the home screen widget (App Group).
//

import Foundation

enum WidgetDataManager {
    static let appGroupID = "group.com.tidystep.app"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Call when sessions or reminder settings change.
    static func update(sessions: [CleaningSession], reminderEnabled: Bool, reminderHour: Int, reminderMinute: Int, reminderWeekday: Int, reminderIntervalDays: Int) {
        guard let def = sharedDefaults else { return }
        let cal = Calendar.current
        let now = Date()
        let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let sessionsThisWeek = sessions.filter { $0.endDate >= weekStart }.count
        def.set(sessionsThisWeek, forKey: "widget_sessions_this_week")
        if let last = sessions.first?.endDate {
            def.set(last.timeIntervalSince1970, forKey: "widget_last_session_date")
        } else {
            def.removeObject(forKey: "widget_last_session_date")
        }
        def.set(reminderEnabled, forKey: "widget_reminder_enabled")
        def.set(reminderHour, forKey: "widget_reminder_hour")
        def.set(reminderMinute, forKey: "widget_reminder_minute")
        def.set(reminderWeekday, forKey: "widget_reminder_weekday")
        def.set(reminderIntervalDays, forKey: "widget_reminder_interval_days")
    }
}
