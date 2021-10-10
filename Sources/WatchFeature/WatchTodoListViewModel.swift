import CoreDataModels
import DatabaseClients
import Foundation

public final class WatchTodoListViewModel: ObservableObject {
    @Published
    private(set) var todos: [Todo] = []

    private let todoClient: TodoClient

    public init(todoClient: TodoClient) {
        self.todoClient = todoClient

        fetch()
    }

    func fetch() {
        todos = todoClient.fetch(
            predicate: nil,
            sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true)]
        )

        print(todos)
    }

    @MainActor
    func todoListRowViewModel(todo: Todo) -> WatchTodoListRowViewModel {
        WatchTodoListRowViewModel(todo: todo) { todo in
            Task {
                try? await self.todoClient.changeCompleteTodo(id: todo.id, isComplete: !todo.isCompleted)

                self.fetch()
            }
        }
    }
}
