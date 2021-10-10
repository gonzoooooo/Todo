import CoreDataModels
import DatabaseClients
import SwiftUI

@available(watchOS 8, *)
public struct WatchTodoListView: View {
    @ObservedObject
    private var viewModel: WatchTodoListViewModel

    public init(viewModel: WatchTodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List{
            ForEach(viewModel.todos, id: \.id) { todo in
                WatchTodoListRow(
                    viewModel: viewModel.todoListRowViewModel(todo: todo)
                )
            }
        }
        .navigationTitle("Todo")
    }
}

