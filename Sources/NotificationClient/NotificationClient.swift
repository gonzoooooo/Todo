import Foundation
import NotificationActions
import UserNotifications

public final class NotificationClient: NSObject {
    public static let shared = NotificationClient()

    public let notificationCenter = UNUserNotificationCenter.current()

    public override init() {
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

    public func register(request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
                print("error: \(error)")
            }
        }
    }

    public func cancel(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}

extension NotificationClient: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]

    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await NotificationAction(rawValue: response.actionIdentifier)?.handleNotificationAction(with: response.notification.request.content.userInfo)
    }
}
