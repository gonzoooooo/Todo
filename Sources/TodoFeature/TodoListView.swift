import CommonViews
import CoreData
import CoreDataModels
import DatabaseClients
import NotificationHelper
import SwiftUI

public struct TodoListView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>

    @State
    private var isHiddenCompletedTodos = false

    private var isHiddenUnflaggedTodos: Bool

    @State
    private var searchText = ""

    @State
    private var editMode: EditMode = .inactive

    @State
    private var selectMode: SelectMode = .inactive

    @State
    private var selection: Set<UUID> = []

    @State
    private var presentingNewTodoView = false

    @State
    private var presentedTodo: Todo?

    @State
    private var presentedConfirmationForRemoveTasks = false

    var todoProvider: TodoProvider

    private var defaultNavigationTitle: String

    public init(
        todoProvider: TodoProvider = .shared,
        isHiddenUnflaggedTodos: Bool = false,
        defaultNavigationTitle: String = String(localized: "Tasks")
    ) {
        self.todoProvider = todoProvider
        self.isHiddenUnflaggedTodos = isHiddenUnflaggedTodos
        self.defaultNavigationTitle = defaultNavigationTitle
    }

    public var body: some View {
        List(selection: $selection) {
            ForEach(todos, id: \.id) { todo in
                Button {
                    presentedTodo = todo
                } label: {
                    TodoListRow(todo: todo) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                        Task {
                            do {
                                try await todoProvider.update(
                                    id: todo.id,
                                    name: todo.name,
                                    isCompleted: !todo.isCompleted,
                                    notifiedDate: todo.notifiedDate,
                                    isFlagged: todo.isFlagged
                                )
                            } catch {
                                print("error: \(error)")
                            }
                        }
                    } flagTapAction: {
                        Task {
                            do {
                                try await todoProvider.update(
                                    id: todo.id,
                                    name: todo.name,
                                    isCompleted: todo.isCompleted,
                                    notifiedDate: todo.notifiedDate,
                                    isFlagged: !todo.isFlagged
                                )
                            } catch {
                                print("error: \(error)")
                            }
                        }
                    }
                    .contextMenu(menuItems: {
                        Button {
                            Task {
                                try? await todoProvider.add(
                                    id: UUID(),
                                    name: todo.name,
                                    notifiedDate: todo.notifiedDate,
                                    isFlagged: todo.isFlagged)
                            }
                        } label: {
                            HStack {
                                Text("Duplicate")
                                Spacer()
                                Image(systemName: "plus.square.on.square")
                            }
                        }

                        Button(role: .destructive) {
                            Task {
                                // FIXME: Crash
                                deleteItems(ids: [todo.id])
                            }
                        } label: {
                            HStack {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    })
                    .environment(\.editMode, $editMode)
                }
            }
            .onDelete(perform: deleteItems)
            .onMove(perform: moveItems)
        }
        .searchable(text: $searchText)
        .refreshable {
            todos.nsPredicate = searchPredicate
        }
        .onAppear {
            todos.nsPredicate = searchPredicate
        }
        .onChange(of: searchText) { _ in
            todos.nsPredicate = searchPredicate
        }
        .onChange(of: isHiddenCompletedTodos) { _ in
            todos.nsPredicate = searchPredicate
        }
        .toolbar(content: toolbarContent)
        .environment(\.editMode, $editMode)
        .navigationTitle(navigationTitle)
        .sheet(isPresented: $presentingNewTodoView) {
            NavigationView {
                NewTodoView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        .sheet(item: $presentedTodo) { todo in
            NavigationView {
                TodoDetailView(
                    id: todo.id,
                    name: todo.name,
                    isCompleted: todo.isCompleted,
                    isNotified: todo.notifiedDate != nil,
                    notifiedDate: todo.notifiedDate ?? Date(),
                    isFlagged: todo.isFlagged) { id in
                        deleteItems(ids: [id])
                    }
            }
        }
        .confirmationDialog(
            Text("Remove Tasks"),
            isPresented: $presentedConfirmationForRemoveTasks
        ) {
            Button(role: .destructive) {
                deleteItems(ids: selection)
                selection = []
            } label: {
                Text("Remove \(selection.count) tasks")
            }
            Button(role: .cancel) {
                presentedConfirmationForRemoveTasks = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This action cannot be undone.")
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

    private func moveItems(from source: IndexSet, to destination: Int) {
        var objectIDs = todos.map { $0.objectID }
        objectIDs.move(fromOffsets: source, toOffset: destination)

        do {
            try todoProvider.updateOrder(objectIDs: objectIDs)
        } catch {
            print("error: \(error)")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        // FIXME: withAnimation is unused
        withAnimation {
            Task {
                do {
                    try await todoProvider.delete(identifiedBy: offsets.map { todos[$0].objectID })
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }

    private func deleteItems(ids: Set<UUID>) {
        // FIXME: withAnimation is unused
        withAnimation {
            Task {
                do {
                    try await todoProvider.delete(ids: ids)
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
}

extension TodoListView {
    var navigationTitle: Text {
        selection.isEmpty ? Text(defaultNavigationTitle) : Text("\(selection.count) Selected")
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if editMode == .active {
                EditButton(editMode: $editMode) {
                    selection.removeAll()
                    editMode = .inactive
                    selectMode = .inactive
                }
            }

            if editMode == .inactive {
                Button(action: { presentingNewTodoView.toggle() }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }

        ToolbarItemGroup(placement: .navigationBarLeading) {
            if editMode == .active {
                SelectButton(mode: $selectMode) {
                    if selectMode.isActive {
                        selection = Set(todos.map { $0.id })
                    } else {
                        selection = []
                    }
                }
            }
        }

        ToolbarItemGroup(placement: .bottomBar) {
            if editMode == .active {
                Button(role: .destructive) {
                    presentedConfirmationForRemoveTasks.toggle()
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(selection.isEmpty)

                Spacer()
            }
        }

        ToolbarItem(placement: .primaryAction) {
            if editMode == .inactive {
                Menu {
                    Button {
                        editMode = .active
                    } label: {
                        Label("Select", systemImage: "checkmark.circle")
                    }

                    Button {
                        withAnimation {
                            isHiddenCompletedTodos.toggle()
                        }
                    } label: {
                        if isHiddenCompletedTodos {
                            Label("Show completed tasks", systemImage: "eye")
                        } else {
                            Label("Hide completed tasks", systemImage: "eye.slash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TodoListView(todoProvider: .preview)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoListView(todoProvider: .preview)
                    .preferredColorScheme(.dark)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoListView(todoProvider: .preview)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}
