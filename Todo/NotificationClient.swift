//
//  NotificationClient.swift
//  NotificationClient
//
//  Created by gonzoooooo on 2021/09/09.
//

import Foundation
import UserNotifications

final class NotificationClient: NSObject {
    public static let shared = NotificationClient()

    let notificationCenter = UNUserNotificationCenter.current()

    override init() {
        super.init()
        notificationCenter.delegate = self
    }

    public func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound])
        } catch {
            print("error: \(error)")

            return false
        }
    }

    func register(request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
                print("error: \(error)")
            }
        }
    }

    func cancel(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}

extension NotificationClient: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("メッセージ自体をタップ")
        case "CompleteAction":
            print("完了ボタンをタップ")
        default:
            break
        }
    }
}
