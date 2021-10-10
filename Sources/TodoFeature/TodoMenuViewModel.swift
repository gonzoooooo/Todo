import DatabaseClients
import Foundation
import NotificationClient

public enum TodoMenuButtonType {
    case all
    case flagged
}

public final class TodoMenuViewModel: ObservableObject {
    private let todoProvider: TodoProvider
    private let notificationClient: NotificationClient

    public init(todoProvider: TodoProvider, notificationClient: NotificationClient) {
        self.todoProvider = todoProvider
        self.notificationClient = notificationClient
    }

    func todoListViewModel(buttonType: TodoMenuButtonType) -> TodoListViewModel {
        return .init(
            todoProvider: todoProvider,
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
