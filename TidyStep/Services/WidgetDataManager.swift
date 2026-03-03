//
//  WidgetDataManager.swift
//  TidyStep
//
//  Writes summary data for the home screen widget (App Group).
//

import Foundation
import WidgetKit

enum WidgetDataManager {
    static let appGroupID = "group.com.tidystep.app"
    static let widgetKind = "TidyStepWidget"

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
        if let last = sessions.first {
            def.set(last.endDate.timeIntervalSince1970, forKey: "widget_last_session_date")
            def.set(Int(last.durationSeconds), forKey: "widget_last_duration_seconds")
            def.set(last.steps, forKey: "widget_last_steps")
            def.set(last.estimatedCalories, forKey: "widget_last_calories")
        } else {
            def.removeObject(forKey: "widget_last_session_date")
            def.removeObject(forKey: "widget_last_duration_seconds")
            def.removeObject(forKey: "widget_last_steps")
            def.removeObject(forKey: "widget_last_calories")
        }
        def.set(reminderEnabled, forKey: "widget_reminder_enabled")
        def.set(reminderHour, forKey: "widget_reminder_hour")
        def.set(reminderMinute, forKey: "widget_reminder_minute")
        def.set(reminderWeekday, forKey: "widget_reminder_weekday")
        def.set(reminderIntervalDays, forKey: "widget_reminder_interval_days")
        let lang = AppLanguage.shared.resolvedLanguage
        def.set(EncouragementLibrary.phraseForDate(lang: lang, date: Date()), forKey: "widget_encouragement_text")
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    /// 同步当前 App 语言与今日励志语到小组件（App 启动或切换语言时调用）
    static func setAppLanguage(_ lang: String) {
        guard let def = sharedDefaults else { return }
        def.set(lang, forKey: "widget_app_language")
        def.set(EncouragementLibrary.phraseForDate(lang: lang, date: Date()), forKey: "widget_encouragement_text")
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
}
