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

    /// Encouraging messages for the weekly reminder (picked at schedule time).
    private static var weeklyBodyKeys: [String] {
        [
            "notification_weekly_body",
            "notification_weekly_body_2",
            "notification_weekly_body_3",
            "notification_weekly_body_4",
        ]
    }

    func scheduleWeekly(weekday: Int, hour: Int, minute: Int) {
        removeAllReminders()
        let content = UNMutableNotificationContent()
        content.title = AppLanguage.shared.string("notification_weekly_title")
        let bodies = Self.weeklyBodyKeys.map { AppLanguage.shared.string($0) }
        content.body = bodies.randomElement() ?? bodies[0]
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
        let content = UNMutableNotificationContent()
        content.title = AppLanguage.shared.string("notification_weekly_title")
        let bodies = Self.weeklyBodyKeys.map { AppLanguage.shared.string($0) }
        content.body = bodies.randomElement() ?? bodies[0]
        content.sound = .default
        let cal = Calendar.current
        var date = cal.nextDate(after: Date(), matching: DateComponents(hour: hour, minute: minute), matchingPolicy: .nextTime) ?? Date()
        for i in 0..<20 {
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
