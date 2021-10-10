import CoreDataModels
import SwiftUI

final class WatchTodoListRowViewModel: ObservableObject {
    var name: String {
        todo.name
    }

    var isCompleted: Bool {
        todo.isCompleted
    }

    var foregroundColorForName: Color {
        todo.isCompleted ? .secondary : .primary
    }

    var checkImageName: String {
        todo.isCompleted ? "checkmark.circle.fill" : "circle"
    }

    private let todo: Todo
    private let toggleComplete: (Todo) -> Void

    init(todo: Todo, toggleComplete: @escaping (Todo) -> Void) {
        self.todo = todo
        self.toggleComplete = toggleComplete
    }

    func handleToggleComplete() {
        toggleComplete(todo)
    }
}
