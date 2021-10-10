import CoreDataModels
import CommonViews
import Foundation
import SwiftUI
import DatabaseClients

final class TodoListRowViewModel: ObservableObject {
    @Published
    var editMode: EditMode

    var name: String {
        todo.name
    }

    var notificationDateString: String? {
        guard let notificationDate = todo.notifiedDate else { return nil }

        return dateString(from: notificationDate)
    }

    var isCompleted: Bool {
        todo.isCompleted
    }

    var isFlagged: Bool {
        todo.isFlagged
    }

    var order: Int64 {
        todo.order
    }

    private let todo: Todo
    private let todoProvider: TodoProvider

    init(todo: Todo, todoProvider: TodoProvider, editMode: EditMode) {
        self.todo = todo
        self.todoProvider = todoProvider
        self.editMode = editMode
    }

    func check() async throws {
        try await todoProvider.update(
            id: todo.id,
            name: todo.name,
            isCompleted: !todo.isCompleted,
            notifiedDate: todo.notifiedDate,
            isFlagged: todo.isFlagged
        )
    }

    func toggleFlag() async throws {
        try await todoProvider.update(
            id: todo.id,
            name: todo.name,
            isCompleted: todo.isCompleted,
            notifiedDate: todo.notifiedDate,
            isFlagged: !todo.isFlagged
        )
    }

    private func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: date)
    }
}
