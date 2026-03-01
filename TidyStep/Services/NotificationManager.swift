//
//  NotificationManager.swift
//  TidyStep
//

import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let weeklyIdentifier = "clean_house_weekly_reminder"

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
        center.removePendingNotificationRequests(withIdentifiers: [weeklyIdentifier])

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

    func cancelWeekly() {
        center.removePendingNotificationRequests(withIdentifiers: [weeklyIdentifier])
    }

    private init() {}
}
