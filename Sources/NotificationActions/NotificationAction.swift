import DatabaseClients
import UserNotifications

public enum NotificationAction: String {
    case completeAction
}

extension NotificationAction {
    public func handleNotificationAction(with userInfo: [AnyHashable: Any]) async {
        switch self {
        case .completeAction:
            await completeTodo(with: userInfo)
        }
    }

    @MainActor
    private func completeTodo(with userInfo: [AnyHashable: Any]) async {
        guard let uuidString = userInfo["identifier"] as? String, let id = UUID(uuidString: uuidString) else { return }

        do {
            try await TodoClient.shared.completeTodo(id: id)
        } catch {
            print("error: \(error)")
        }
    }
}
