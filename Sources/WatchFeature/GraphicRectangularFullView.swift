#if os(watchOS)
import CoreDataModels
import DatabaseClients
import SwiftUI

public struct GraphicRectangularFullView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>

    private var predicate: NSPredicate {
        return NSPredicate(format: "%K == false", #keyPath(Todo.isCompleted))
    }

    private var todoClient: TodoClient

    public init(todoClient: TodoClient = .shared) {
        self.todoClient = todoClient
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(Image(systemName: "checkmark.circle.fill")) Todo")
                    .bold()
                    .foregroundColor(.accentColor)
                Spacer()
            }

            if todos.isEmpty {
                Text("No Task 👍")
            } else {
                ForEach(todos.prefix(3), id: \.id) { todo in
                    HStack {
                        Text(todo.name)
                            .font(.callout)
                        Spacer()
                    }
                    .padding(.leading, 2)
                }
            }

            Spacer()
        }
        .onAppear {
            todos.nsPredicate = predicate
        }
    }
}

struct GraphicRectangularFullView_Previews: PreviewProvider {
    static var previews: some View {
        let todoClient = TodoClient.preview

        return GraphicRectangularFullView(todoClient: todoClient)
            .environment(\.managedObjectContext, todoClient.persistence.container.viewContext)
    }
}
#endif
