import CoreDataModels
import DatabaseClients
import Foundation
import NotificationClient
import NotificationHelper

final class TodoDetailViewModel: ObservableObject {
    @Published
    var name: String

    @Published
    var isCompleted: Bool

    @Published
    var isNotified: Bool

    @Published
    var notifiedDate: Date

    @Published
    var isFlagged: Bool

    @Published
    var presentedConfirmationForRemoveTask = false

    private let todo: Todo
    private let todoProvider: TodoProvider
    private let notificationClient: NotificationClient

    var isDisabledRegisterButton: Bool {
        return name.isEmpty
    }

    init(
        todo: Todo,
        todoProvider: TodoProvider,
        notificationClient: NotificationClient
    ) {
        self.todo = todo
        self.todoProvider = todoProvider
        self.notificationClient = notificationClient

        self.name = todo.name
        self.isCompleted = todo.isCompleted
        self.isNotified = todo.notifiedDate != nil
        self.notifiedDate = todo.notifiedDate ?? Date()
        self.isFlagged = todo.isFlagged

    }

    func update() async throws {
        try await todoProvider.update(
            id: todo.id,
            name: name,
            isCompleted: isCompleted,
            notifiedDate: isNotified ? notifiedDate : nil,
            isFlagged: isFlagged
        )

        notificationClient.cancel(id: todo.id.uuidString)

        if isNotified {
            notificationClient.register(
                identifier: todo.id,
                name: name,
                date: notifiedDate
            )
        }
    }

    func delete() async {
        try? await todoProvider.delete(ids: [todo.id])
    }
}
