import CommonViews
import CoreDataModels
import SwiftUI

@available(iOS 15, *)
public struct TodoListView: View {
    @ObservedObject
    private var viewModel: TodoListViewModel

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.todos, id: \.id) { todo in
                Button {
                    viewModel.presentedTodo = todo
                } label: {
                    TodoListRow(viewModel: viewModel.todoListRowViewModel(todo: todo))
                        .contextMenu(menuItems: {
                            Button {
                                Task {
                                    try? await viewModel.add(
                                        name: todo.name,
                                        notifiedDate: todo.notifiedDate,
                                        isFlagged: todo.isFlagged
                                    )
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
                                    do {
                                        await viewModel.deleteTodos(ids: [todo.id])
                                    } catch {
                                        print("error: \(error)")
                                    }
                                }
                            } label: {
                                HStack {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    )
                }
            }
            .onDelete { index in
                Task {
                    do {
                        await viewModel.deleteTodos(offsets: index)
                    } catch {
                        print("error: \(error)")
                    }
                }
            }
            .onMove(perform: viewModel.moveTodos)
        }
        .searchable(text: $viewModel.searchText)
        .refreshable {
            viewModel.fetch()
        }
        .onAppear(perform: viewModel.fetch)
        .onChange(of: viewModel.searchText) { _ in
            viewModel.fetch()
        }
        .onChange(of: viewModel.isHiddenCompletedTodos) { _ in
            viewModel.fetch()
        }
        .toolbar(content: toolbarContent)
        .environment(\.editMode, $viewModel.editMode)
        .navigationTitle(viewModel.navigationTitle)
        .sheet(isPresented: $viewModel.presentingNewTodoView) {
            NavigationView {
                NewTodoView(viewModel: viewModel.newTodoViewModel)
            }
        }
        .sheet(item: $viewModel.presentedTodo) { todo in
            NavigationView {
                TodoDetailView(viewModel: viewModel.todoDetailViewModel(todo: todo))
            }
        }
        .confirmationDialog(
            Text("Remove Tasks"),
            isPresented: $viewModel.presentedConfirmationForRemoveTasks
        ) {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteTodos(ids: viewModel.selection)
                    viewModel.selection = []
                }
            } label: {
                Text("Remove \(viewModel.selection.count) tasks")
            }

            Button(role: .cancel) {
                viewModel.presentedConfirmationForRemoveTasks = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

extension TodoListView {
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if viewModel.editMode == .active {
                EditButton(editMode: $viewModel.editMode) {
                    viewModel.selection.removeAll()
                    viewModel.editMode = .inactive
                    viewModel.selectMode = .inactive
                }
            }

            if viewModel.editMode == .inactive {
                Button(action: { viewModel.presentingNewTodoView.toggle() }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }

        ToolbarItemGroup(placement: .navigationBarLeading) {
            if viewModel.editMode == .active {
                SelectButton(mode: $viewModel.selectMode) {
                    if viewModel.selectMode.isActive {
                        viewModel.selection = Set(viewModel.todos.map { $0.id })
                    } else {
                        viewModel.selection = []
                    }
                }
            }
        }

        ToolbarItemGroup(placement: .bottomBar) {
            if viewModel.editMode == .active {
                Button(role: .destructive) {
                    viewModel.presentedConfirmationForRemoveTasks.toggle()
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(viewModel.selection.isEmpty)

                Spacer()
            }
        }

        ToolbarItem(placement: .primaryAction) {
            if viewModel.editMode == .inactive {
                Menu {
                    Button {
                        viewModel.editMode = .active
                    } label: {
                        Label("Select", systemImage: "checkmark.circle")
                    }

                    Button {
                        withAnimation {
                            viewModel.isHiddenCompletedTodos.toggle()
                        }
                    } label: {
                        if viewModel.isHiddenCompletedTodos {
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

#if DEBUG

import DatabaseClients
import NotificationClient

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        let todoClient = TodoClient.preview
        let notificationClient = NotificationClient.shared

        return Group {
            NavigationView {
                TodoListView(
                    viewModel: .init(
                        todoClient: todoClient, notificationClient: notificationClient
                    )
                )
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoListView(
                    viewModel: .init(
                        todoClient: todoClient, notificationClient: notificationClient
                    )
                )
                .preferredColorScheme(.dark)
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoListView(
                    viewModel: .init(
                        todoClient: todoClient, notificationClient: notificationClient
                    )
                )
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}

#endif
