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
    private let todoClient: TodoClient

    init(todo: Todo, todoClient: TodoClient, editMode: EditMode) {
        self.todo = todo
        self.todoClient = todoClient
        self.editMode = editMode
    }

    func check() async throws {
        try await todoClient.update(
            id: todo.id,
            name: todo.name,
            isCompleted: !todo.isCompleted,
            notifiedDate: todo.notifiedDate,
            isFlagged: todo.isFlagged
        )
    }

    func toggleFlag() async throws {
        try await todoClient.update(
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
