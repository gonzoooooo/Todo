import CoreDataModels
import DatabaseClients
import Foundation

public final class WatchTodoListViewModel: ObservableObject {
    @Published
    private(set) var todos: [Todo] = []

    private let todoProvider: TodoProvider

    public init(todoProvider: TodoProvider) {
        self.todoProvider = todoProvider

        fetch()
    }

    func fetch() {
        todos = todoProvider.fetch(
            predicate: nil,
            sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true)]
        )

        print(todos)
    }

    @MainActor
    func todoListRowViewModel(todo: Todo) -> WatchTodoListRowViewModel {
        WatchTodoListRowViewModel(todo: todo) { todo in
            Task {
                try? await self.todoProvider.changeCompleteTodo(id: todo.id, isComplete: !todo.isCompleted)

                self.fetch()
            }
        }
    }
}
