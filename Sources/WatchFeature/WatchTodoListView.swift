import CoreDataModels
import DatabaseClients
import SwiftUI

@available(watchOS 8, *)
public struct WatchTodoListView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>

    var todoProvider: TodoProvider

    public init(todoProvider: TodoProvider = .shared) {
        self.todoProvider = todoProvider
    }

    public var body: some View {
        List() {
            ForEach(todos, id: \.id) { todo in
                WatchTodoListRow(todo: todo) {
                    Task {
                        try? await todoProvider.changeCompleteTodo(id: todo.id, isComplete: !todo.isCompleted)
                    }
                }
            }
        }
        .navigationTitle("Todo")
    }
}

@available(watchOS 8, *)
struct WatchTodoListRow: View {
    var todo: Todo

    var tapAction: () -> Void = {}

    private var foregroundColorForName: Color {
        todo.isCompleted ? .secondary : .primary
    }

    var body: some View {
        Button {
            tapAction()
        } label: {
            HStack {
                if todo.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Image(systemName: "circle")
                }

                VStack(alignment: .leading) {
                    Text(todo.name)
                        .foregroundColor(foregroundColorForName)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    Spacer(minLength: 8)
                }

                Spacer()
            }
        }
    }
}
