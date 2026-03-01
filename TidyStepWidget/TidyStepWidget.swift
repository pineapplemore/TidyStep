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

/// 小组件文案，与 App 语言一致（en / zh-Hans）
private enum WidgetStrings {
    static func title(_ lang: String) -> String { lang == "zh-Hans" ? "TidyStep" : "TidyStep" }
    static func sessions(_ lang: String) -> String { lang == "zh-Hans" ? "次" : "sessions" }
    static func sessionsThisWeek(_ lang: String) -> String { lang == "zh-Hans" ? "本周次数" : "sessions this week" }
    static func noTidyYet(_ lang: String) -> String { lang == "zh-Hans" ? "还没有整理" : "No tidy yet" }
    static func today(_ lang: String) -> String { lang == "zh-Hans" ? "今天" : "Today" }
    static func yesterday(_ lang: String) -> String { lang == "zh-Hans" ? "昨天" : "Yesterday" }
    static func daysAgo(_ lang: String, days: Int) -> String {
        lang == "zh-Hans" ? "\(days) 天前" : "\(days) days ago"
    }
    /// 小组件未收到 App 写入时的兜底句
    static func fallbackEncouragement(_ lang: String) -> String {
        lang == "zh-Hans" ? "今天开始整理吧！" : "Start a tidy today!"
    }
}

struct TidyStepEntry: TimelineEntry {
    let date: Date
    let sessionsThisWeek: Int
    let lastSessionDate: Date?
    let reminderEnabled: Bool
    let reminderText: String
    /// "en" or "zh-Hans", from App Group (app syncs when language changes)
    let appLanguage: String
    /// 今日励志语，由主 App 写入 App Group（与推送共用 EncouragementLibrary）
    let widgetEncouragementText: String
}

struct TidyStepProvider: TimelineProvider {
    func placeholder(in context: Context) -> TidyStepEntry {
        TidyStepEntry(date: Date(), sessionsThisWeek: 0, lastSessionDate: nil, reminderEnabled: false, reminderText: "", appLanguage: "en", widgetEncouragementText: "")
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
        let appLanguage = def?.string(forKey: "widget_app_language")
            ?? (Self.regionCode == "CN" ? "zh-Hans" : "en")
        let sessionsThisWeek = def?.integer(forKey: "widget_sessions_this_week") ?? 0
        let lastTs = def?.double(forKey: "widget_last_session_date")
        let lastSessionDate = lastTs.map { Date(timeIntervalSince1970: $0) }
        let reminderEnabled = def?.bool(forKey: "widget_reminder_enabled") ?? false
        let hour = def?.integer(forKey: "widget_reminder_hour") ?? 20
        let minute = def?.integer(forKey: "widget_reminder_minute") ?? 0
        let intervalDays = def?.integer(forKey: "widget_reminder_interval_days") ?? 0
        let reminderText = formatReminderText(lang: appLanguage, intervalDays: intervalDays, hour: hour, minute: minute, enabled: reminderEnabled)
        let encouragementText = def?.string(forKey: "widget_encouragement_text") ?? ""
        return TidyStepEntry(
            date: Date(),
            sessionsThisWeek: sessionsThisWeek,
            lastSessionDate: lastSessionDate,
            reminderEnabled: reminderEnabled,
            reminderText: reminderText,
            appLanguage: appLanguage,
            widgetEncouragementText: encouragementText
        )
    }

    /// 用 countryCode 判断地区（iOS 15 无 Locale.region，全程用 NSLocale）
    private static var regionCode: String? {
        (Locale.current as NSLocale).object(forKey: .countryCode) as? String
    }

    private func formatReminderText(lang: String, intervalDays: Int, hour: Int, minute: Int, enabled: Bool) -> String {
        guard enabled else { return "" }
        let time = String(format: "%02d:%02d", hour, minute)
        if intervalDays == 0 {
            return time
        }
        return lang == "zh-Hans"
            ? String(format: "每%d天 · %@", intervalDays, time)
            : String(format: "Every %d days · %@", intervalDays, time)
    }
}

struct TidyStepWidgetView: View {
    var entry: TidyStepEntry
    @Environment(\.widgetFamily) var family

    private let backgroundColor = Color(red: 0.08, green: 0.08, blue: 0.10)
    private let titleColor = Color(red: 0.55, green: 0.58, blue: 0.65)
    private let valueColor = Color.white
    private let labelColor = Color(red: 0.60, green: 0.63, blue: 0.70)
    private let mintColor = Color(red: 94/255, green: 234/255, blue: 212/255)

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        let lang = entry.appLanguage
        return ZStack(alignment: .bottomTrailing) {
            backgroundColor
            VStack(alignment: .leading, spacing: 6) {
                Text(WidgetStrings.title(lang))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(titleColor)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.sessionsThisWeek)")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(valueColor)
                    Text(WidgetStrings.sessions(lang))
                        .font(.caption2)
                        .foregroundColor(labelColor)
                }
                if let last = entry.lastSessionDate {
                    Text(daysAgo(last, lang: lang))
                        .font(.caption2)
                        .foregroundColor(labelColor)
                } else {
                    Text(WidgetStrings.noTidyYet(lang))
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
            Image("WidgetIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .padding(8)
        }
        .clipped()
    }

    private var mediumView: some View {
        let lang = entry.appLanguage
        let iconWidth: CGFloat = 72
        let iconPadding: CGFloat = 8
        let trailingForIcon = iconWidth + iconPadding * 2
        return ZStack(alignment: .bottomTrailing) {
            backgroundColor
            VStack(alignment: .leading, spacing: 4) {
                Text(WidgetStrings.title(lang))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(titleColor)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(entry.sessionsThisWeek)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(valueColor)
                    Text(WidgetStrings.sessionsThisWeek(lang))
                        .font(.system(size: 9))
                        .foregroundColor(labelColor)
                }
                if let last = entry.lastSessionDate {
                    Text(daysAgo(last, lang: lang))
                        .font(.system(size: 9))
                        .foregroundColor(labelColor)
                } else {
                    Text(WidgetStrings.noTidyYet(lang))
                        .font(.system(size: 9))
                        .foregroundColor(labelColor.opacity(0.8))
                }
                if entry.reminderEnabled && !entry.reminderText.isEmpty {
                    Text(entry.reminderText)
                        .font(.system(size: 8))
                        .foregroundColor(labelColor.opacity(0.7))
                }
                Spacer(minLength: 6)
                Text(entry.widgetEncouragementText.isEmpty ? WidgetStrings.fallbackEncouragement(lang) : entry.widgetEncouragementText)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(mintColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .padding(.trailing, 12)
                    .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 22, leading: 18, bottom: 24, trailing: trailingForIcon + 8))
            Image("WidgetIcon")
                .resizable()
                .scaledToFit()
                .frame(width: iconWidth, height: iconWidth)
                .padding(iconPadding)
        }
        .clipped()
    }

    private func daysAgo(_ date: Date, lang: String) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days == 0 { return WidgetStrings.today(lang) }
        if days == 1 { return WidgetStrings.yesterday(lang) }
        return WidgetStrings.daysAgo(lang, days: days)
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
