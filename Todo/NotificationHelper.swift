//
//  NotificationHelper.swift
//  NotificationHelper
//
//  Created by gonzoooooo on 2021/09/10.
//

import Foundation
import UserNotifications

extension NotificationClient {
    func register(identifier: UUID, name: String, date: Date) {
        let action = UNNotificationAction(identifier: "CompleteAction", title: "完了", options: .foreground)
        let categoryIdentifier = "todo"
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [action], intentIdentifiers: [])
        notificationCenter.setNotificationCategories([category])

        let content = UNMutableNotificationContent()
        content.title = "Todo"
        content.body = name
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier

        let dateComponents = DateComponents(
            year: Calendar.current.component(.year, from: date),
            month: Calendar.current.component(.month, from: date),
            day: Calendar.current.component(.day, from: date),
            hour: Calendar.current.component(.hour, from: date),
            minute: Calendar.current.component(.minute, from: date)
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)


        let request = UNNotificationRequest(
            identifier: identifier.uuidString,
            content: content,
            trigger: trigger
        )

        self.register(request: request)
    }
}
