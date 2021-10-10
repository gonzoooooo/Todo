import Foundation
import DatabaseClients
import NotificationClient
import NotificationHelper

final class NewTodoViewModel: ObservableObject {
    @Published
    var name = ""

    @Published
    var isFlagged = false

    @Published
    var isNotified = false

    @Published
    var notifiedDate: Date = Date()

    var isDisabledRegisterButton: Bool {
        return name.isEmpty
    }

    private let todoProvider: TodoProvider
    private let notificationClient: NotificationClient

    init(todoProvider: TodoProvider, notificationClient: NotificationClient) {
        self.todoProvider = todoProvider
        self.notificationClient = notificationClient
    }

    func register() async {
        do {
            let id = UUID()

            try await todoProvider.add(
                id: id,
                name: name,
                notifiedDate: isNotified ? notifiedDate : nil,
                isFlagged: isFlagged
            )

            if isNotified {
                notificationClient.register(
                    identifier: id,
                    name: name,
                    date: notifiedDate
                )
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
