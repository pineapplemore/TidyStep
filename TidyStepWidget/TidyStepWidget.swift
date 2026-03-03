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
    static func minutes(_ lang: String) -> String { lang == "zh-Hans" ? "分钟" : "min" }
    static func stepsLabel(_ lang: String) -> String { lang == "zh-Hans" ? "步" : "steps" }
    static func caloriesLabel(_ lang: String) -> String { lang == "zh-Hans" ? "卡" : "cal" }
    /// 小组件未收到 App 写入时的兜底句
    static func fallbackEncouragement(_ lang: String) -> String {
        lang == "zh-Hans" ? "今天开始整理吧！" : "Start a tidy today!"
    }
}

struct TidyStepEntry: TimelineEntry {
    let date: Date
    let sessionsThisWeek: Int
    let lastSessionDate: Date?
    let lastSessionDurationSeconds: Int?
    let lastSessionSteps: Int?
    let lastSessionCalories: Double?
    let reminderEnabled: Bool
    let reminderText: String
    /// "en" or "zh-Hans", from App Group (app syncs when language changes)
    let appLanguage: String
    /// 今日励志语，由主 App 写入 App Group（与推送共用 EncouragementLibrary）
    let widgetEncouragementText: String
}

struct TidyStepProvider: TimelineProvider {
    func placeholder(in context: Context) -> TidyStepEntry {
        TidyStepEntry(date: Date(), sessionsThisWeek: 0, lastSessionDate: nil, lastSessionDurationSeconds: nil, lastSessionSteps: nil, lastSessionCalories: nil, reminderEnabled: false, reminderText: "", appLanguage: "en", widgetEncouragementText: "")
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
        let lastTs = def?.object(forKey: "widget_last_session_date") as? Double
        let lastSessionDate: Date? = {
            guard let ts = lastTs, ts > 0 else { return nil }
            let d = Date(timeIntervalSince1970: ts)
            return d <= Date() ? d : nil
        }()
        let reminderEnabled = def?.bool(forKey: "widget_reminder_enabled") ?? false
        let hour = def?.integer(forKey: "widget_reminder_hour") ?? 20
        let minute = def?.integer(forKey: "widget_reminder_minute") ?? 0
        let intervalDays = def?.integer(forKey: "widget_reminder_interval_days") ?? 0
        let reminderText = formatReminderText(lang: appLanguage, intervalDays: intervalDays, hour: hour, minute: minute, enabled: reminderEnabled)
        let encouragementText = def?.string(forKey: "widget_encouragement_text") ?? ""
        let lastDuration = def?.object(forKey: "widget_last_duration_seconds") as? Int
        let lastSteps = def?.object(forKey: "widget_last_steps") as? Int
        let lastCalories = def?.object(forKey: "widget_last_calories") as? Double
        return TidyStepEntry(
            date: Date(),
            sessionsThisWeek: sessionsThisWeek,
            lastSessionDate: lastSessionDate,
            lastSessionDurationSeconds: lastDuration,
            lastSessionSteps: lastSteps,
            lastSessionCalories: lastCalories,
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
        GeometryReader { geo in
            ZStack {
                backgroundColor
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea(.all)
                Group {
                    switch family {
                    case .systemMedium:
                        mediumView
                    default:
                        smallView
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var smallView: some View {
        let lang = entry.appLanguage
        let contentPadding: CGFloat = 14
        let iconPadding: CGFloat = 10
        return ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 5) {
                Text(WidgetStrings.title(lang))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(titleColor)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.sessionsThisWeek)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(valueColor)
                    Text(WidgetStrings.sessions(lang))
                        .font(.caption2)
                        .foregroundColor(labelColor)
                }
                if let last = entry.lastSessionDate {
                    Text(daysAgo(last, lang: lang))
                        .font(.system(size: 9))
                        .foregroundColor(labelColor)
                        .lineLimit(1)
                    if let dur = entry.lastSessionDurationSeconds, let steps = entry.lastSessionSteps, let cal = entry.lastSessionCalories {
                        Text(formatLastSessionLine(durationSeconds: dur, steps: steps, calories: cal, lang: lang))
                            .font(.system(size: 8))
                            .foregroundColor(labelColor.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                } else {
                    Text(WidgetStrings.noTidyYet(lang))
                        .font(.system(size: 9))
                        .foregroundColor(labelColor.opacity(0.8))
                        .lineLimit(1)
                }
                if entry.reminderEnabled && !entry.reminderText.isEmpty {
                    Text(entry.reminderText)
                        .font(.system(size: 8))
                        .foregroundColor(labelColor.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(contentPadding)
            Image("WidgetIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .padding(iconPadding)
        }
    }

    private var mediumView: some View {
        let lang = entry.appLanguage
        let iconWidth: CGFloat = 68
        let contentPadding: CGFloat = 16
        let iconPadding: CGFloat = 10
        let trailingForIcon = iconWidth + iconPadding * 2
        return ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 4) {
                Text(WidgetStrings.title(lang))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(titleColor)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(entry.sessionsThisWeek)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
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
                        .lineLimit(1)
                    if let dur = entry.lastSessionDurationSeconds, let steps = entry.lastSessionSteps, let cal = entry.lastSessionCalories {
                        Text(formatLastSessionLine(durationSeconds: dur, steps: steps, calories: cal, lang: lang))
                            .font(.system(size: 9))
                            .foregroundColor(labelColor.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                } else {
                    Text(WidgetStrings.noTidyYet(lang))
                        .font(.system(size: 9))
                        .foregroundColor(labelColor.opacity(0.8))
                        .lineLimit(1)
                }
                if entry.reminderEnabled && !entry.reminderText.isEmpty {
                    Text(entry.reminderText)
                        .font(.system(size: 8))
                        .foregroundColor(labelColor.opacity(0.7))
                        .lineLimit(1)
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
                    .padding(.trailing, 8)
                    .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: contentPadding, leading: contentPadding, bottom: contentPadding + 4, trailing: trailingForIcon + contentPadding))
            Image("WidgetIcon")
                .resizable()
                .scaledToFit()
                .frame(width: iconWidth, height: iconWidth)
                .padding(iconPadding)
        }
    }

    private func formatLastSessionLine(durationSeconds: Int, steps: Int, calories: Double, lang: String) -> String {
        let min = durationSeconds / 60
        if lang == "zh-Hans" {
            return "\(min)\(WidgetStrings.minutes(lang)) · \(steps)\(WidgetStrings.stepsLabel(lang)) · \(Int(calories))\(WidgetStrings.caloriesLabel(lang))"
        }
        return "\(min) \(WidgetStrings.minutes(lang)) · \(steps) \(WidgetStrings.stepsLabel(lang)) · \(Int(calories)) \(WidgetStrings.caloriesLabel(lang))"
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
        // 若使用 Xcode 15+ / iOS 17 SDK，可取消下行注释以取消系统 margin、让背景铺满：.contentMarginsDisabled()
    }
}
