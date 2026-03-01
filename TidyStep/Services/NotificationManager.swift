//
//  NotificationManager.swift
//  TidyStep
//

import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let weeklyIdentifier = "tidystep_weekly_reminder"
    private let intervalIdentifierPrefix = "tidystep_interval_"

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleWeekly(weekday: Int, hour: Int, minute: Int) {
        removeAllReminders()
        let lang = AppLanguage.shared.resolvedLanguage
        let content = UNMutableNotificationContent()
        content.title = AppLanguage.shared.string("notification_weekly_title")
        content.body = EncouragementLibrary.phraseForDate(lang: lang, date: Date())
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    /// Schedule reminders every N days at the given time (up to 20 occurrences).
    func scheduleInterval(days: Int, hour: Int, minute: Int) {
        removeAllReminders()
        let lang = AppLanguage.shared.resolvedLanguage
        let cal = Calendar.current
        var date = cal.nextDate(after: Date(), matching: DateComponents(hour: hour, minute: minute), matchingPolicy: .nextTime) ?? Date()
        for i in 0..<20 {
            let content = UNMutableNotificationContent()
            content.title = AppLanguage.shared.string("notification_weekly_title")
            content.body = EncouragementLibrary.phraseForDate(lang: lang, date: date)
            content.sound = .default
            let dc = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
            let request = UNNotificationRequest(identifier: "\(intervalIdentifierPrefix)\(i)", content: content, trigger: trigger)
            center.add(request)
            guard let next = cal.date(byAdding: .day, value: days, to: date) else { break }
            date = next
        }
    }

    private func removeAllReminders() {
        var ids = [weeklyIdentifier]
        for i in 0..<20 { ids.append("\(intervalIdentifierPrefix)\(i)") }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func cancelWeekly() {
        removeAllReminders()
    }

    private init() {}
}
