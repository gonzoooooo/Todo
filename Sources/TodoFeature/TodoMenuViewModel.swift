import DatabaseClients
import Foundation
import NotificationClient

public enum TodoMenuButtonType {
    case all
    case flagged
}

public final class TodoMenuViewModel: ObservableObject {
    private let todoClient: TodoClient
    private let notificationClient: NotificationClient

    public init(todoClient: TodoClient, notificationClient: NotificationClient) {
        self.todoClient = todoClient
        self.notificationClient = notificationClient
    }

    func todoListViewModel(buttonType: TodoMenuButtonType) -> TodoListViewModel {
        return .init(
            todoClient: todoClient,
            notificationClient: notificationClient,
            defaultNavigationTitle: navigationTitle(buttonType: buttonType)
        )
    }

    private func navigationTitle(buttonType: TodoMenuButtonType) -> String {
        switch buttonType {
        case .all:
            return String(localized: "All")
        case .flagged:
            return String(localized: "Flagged")
        }
    }
}
