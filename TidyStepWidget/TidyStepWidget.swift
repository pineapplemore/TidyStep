//
//  TidyStepWidget.swift
//  TidyStepWidget
//
//  Add this target in Xcode: File > New > Target > Widget Extension.
//  Name: TidyStepWidget. Add App Group: group.com.tidystep.app
//

import WidgetKit
import SwiftUI

private let appGroupID = "group.com.tidystep.app"

struct TidyStepEntry: TimelineEntry {
    let date: Date
    let sessionsThisWeek: Int
    let lastSessionDate: Date?
    let reminderEnabled: Bool
    let reminderText: String
}

struct TidyStepProvider: TimelineProvider {
    func placeholder(in context: Context) -> TidyStepEntry {
        TidyStepEntry(date: Date(), sessionsThisWeek: 0, lastSessionDate: nil, reminderEnabled: false, reminderText: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (TidyStepEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TidyStepEntry>) -> Void) {
        let entry = readEntry()
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func readEntry() -> TidyStepEntry {
        let def = UserDefaults(suiteName: appGroupID)
        let sessionsThisWeek = def?.integer(forKey: "widget_sessions_this_week") ?? 0
        let lastTs = def?.double(forKey: "widget_last_session_date")
        let lastSessionDate = lastTs.map { Date(timeIntervalSince1970: $0) }
        let reminderEnabled = def?.bool(forKey: "widget_reminder_enabled") ?? false
        let hour = def?.integer(forKey: "widget_reminder_hour") ?? 20
        let minute = def?.integer(forKey: "widget_reminder_minute") ?? 0
        let intervalDays = def?.integer(forKey: "widget_reminder_interval_days") ?? 0
        var reminderText = ""
        if reminderEnabled {
            if intervalDays == 0 {
                reminderText = String(format: "%02d:%02d", hour, minute)
            } else {
                reminderText = String(format: "Every %d days · %02d:%02d", intervalDays, hour, minute)
            }
        }
        return TidyStepEntry(
            date: Date(),
            sessionsThisWeek: sessionsThisWeek,
            lastSessionDate: lastSessionDate,
            reminderEnabled: reminderEnabled,
            reminderText: reminderText
        )
    }
}

struct TidyStepWidgetView: View {
    var entry: TidyStepEntry

    private let backgroundColor = Color(red: 0.08, green: 0.08, blue: 0.10)
    private let titleColor = Color(red: 0.55, green: 0.58, blue: 0.65)
    private let valueColor = Color.white
    private let labelColor = Color(red: 0.60, green: 0.63, blue: 0.70)

    var body: some View {
        ZStack {
            backgroundColor
            VStack(alignment: .leading, spacing: 6) {
                Text("TidyStep")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(titleColor)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.sessionsThisWeek)")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(valueColor)
                    Text("sessions")
                        .font(.caption2)
                        .foregroundColor(labelColor)
                }
                if let last = entry.lastSessionDate {
                    Text(daysAgo(last))
                        .font(.caption2)
                        .foregroundColor(labelColor)
                } else {
                    Text("No tidy yet")
                        .font(.caption2)
                        .foregroundColor(labelColor.opacity(0.8))
                }
                if entry.reminderEnabled && !entry.reminderText.isEmpty {
                    Text(entry.reminderText)
                        .font(.system(size: 9))
                        .foregroundColor(labelColor.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(12)
        }
    }

    private func daysAgo(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        return "\(days) days ago"
    }
}

@main
struct TidyStepWidget: Widget {
    let kind: String = "TidyStepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TidyStepProvider()) { entry in
            TidyStepWidgetView(entry: entry)
        }
        .configurationDisplayName("TidyStep")
        .description("This week's sessions and last tidy.")
        .supportedFamilies([.systemSmall])
    }
}
