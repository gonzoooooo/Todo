import CoreDataModels
import CommonViews
import DatabaseClients
import Foundation
import SwiftUI
import NotificationClient

public final class TodoListViewModel: NSObject, ObservableObject {
    @Published
    private(set) var todos: [Todo] = []

    @Published
    var isHiddenCompletedTodos = false

    @Published
    private(set) var isHiddenUnflaggedTodos = false

    @Published
    var searchText = ""

    @Published
    var editMode: EditMode = .inactive

    @Published
    var selectMode: SelectMode = .inactive

    @Published
    var selection: Set<UUID> = []

    @Published
    var presentingNewTodoView = false

    @Published
    var presentedTodo: Todo?

    @Published
    var presentedConfirmationForRemoveTasks = false

    private(set) var defaultNavigationTitle: String

    private let todoProvider: TodoProvider
    private let notificationClient: NotificationClient

    var navigationTitle: Text {
        selection.isEmpty ? Text(defaultNavigationTitle) : Text("\(selection.count) Selected")
    }

    var newTodoViewModel: NewTodoViewModel {
        .init(todoProvider: todoProvider, notificationClient: notificationClient)
    }

    public init(
        todoProvider: TodoProvider,
        notificationClient: NotificationClient,
        isHiddenUnflaggedTodos: Bool = false,
        defaultNavigationTitle: String = String(localized: "Tasks")
    ) {
        self.todoProvider = todoProvider
        self.notificationClient = notificationClient
        self.isHiddenUnflaggedTodos = isHiddenUnflaggedTodos
        self.defaultNavigationTitle = defaultNavigationTitle
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextObjectsDidChange(_:)),
            name: Notification.Name.NSManagedObjectContextObjectsDidChange,
            object: nil
        )

        fetch()
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name.NSManagedObjectContextObjectsDidChange,
            object: nil
        )
    }

    func fetch() {
        todos = todoProvider.fetch(
            predicate: searchPredicate,
            sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true)]
        )
    }

    public func add(
        name: String,
        notifiedDate: Date?,
        isFlagged: Bool
    ) async throws {
        try? await todoProvider.add(
            id: UUID(),
            name: name,
            notifiedDate: notifiedDate,
            isFlagged: isFlagged
        )
    }

    func moveTodos(from source: IndexSet, to destination: Int) {
        var objectIDs = todos.map { $0.objectID }
        objectIDs.move(fromOffsets: source, toOffset: destination)

        do {
            try todoProvider.updateOrder(objectIDs: objectIDs)
        } catch {
            print("error: \(error)")
        }
    }

    func deleteTodos(offsets: IndexSet) async throws {
        try await todoProvider.delete(identifiedBy: offsets.map { todos[$0].objectID })
    }

    func deleteTodos(ids: Set<UUID>) async throws {
        try await todoProvider.delete(ids: ids)
    }

    func todoListRowViewModel(todo: Todo) -> TodoListRowViewModel {
        TodoListRowViewModel(
            todo: todo,
            todoProvider: todoProvider,
            editMode: editMode
        )
    }

    func todoDetailViewModel(todo: Todo) -> TodoDetailViewModel {
        TodoDetailViewModel(
            todo: todo,
            todoProvider: todoProvider,
            notificationClient: notificationClient
        )
    }

    @objc
    func contextObjectsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.fetch()
        }
    }

    private var searchPredicate: NSPredicate {
        var predicates = [NSPredicate]()

        if isHiddenUnflaggedTodos {
            predicates.append(NSPredicate(format: "%K == true", #keyPath(Todo.isFlagged)))
        }

        if isHiddenCompletedTodos {
            predicates.append(NSPredicate(format: "%K == false", #keyPath(Todo.isCompleted)))
        }

        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "%K BEGINSWITH[cd] %@", #keyPath(Todo.name), searchText))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
