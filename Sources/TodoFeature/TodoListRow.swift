import CoreDataModels
import SwiftUI

@available(iOS 15, *)
struct TodoListRow: View {
    @ObservedObject
    private var viewModel: TodoListRowViewModel

    init(viewModel: TodoListRowViewModel) {
        self.viewModel = viewModel
    }

    private var foregroundColorForName: Color {
        viewModel.isCompleted ? .secondary : .primary
    }

    var body: some View {
        HStack {
            if viewModel.editMode == .inactive {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    Task {
                        do {
                            try await viewModel.check()
                        } catch {
                            print("error: \(error)")
                        }
                    }
                } label: {
                    if viewModel.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .font(.title2)
                    }
                }
            }

            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .foregroundColor(foregroundColorForName)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                if let notifiedDateString = viewModel.notificationDateString {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.systemRed)
                        Text(notifiedDateString)
                            .font(.caption)
                            .foregroundColor(.systemRed)
                    }
                    .padding(.bottom, 4)
                }

                Text("Order: \(viewModel.order)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer(minLength: 8)
            }

            Spacer()

            Button {
                Task {
                    do {
                        try await viewModel.toggleFlag()
                    } catch {
                        print("error: \(error)")
                    }
                }
            } label: {
                if viewModel.isFlagged {
                    Image(systemName: "flag.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                } else {
                    Image(systemName: "flag.circle")
                        .foregroundColor(.systemGray)
                        .font(.title2)
                }
            }
        }
        .frame(minHeight: 60)
        .environment(\.editMode, $viewModel.editMode)
    }
}

#if DEBUG

import DatabaseClients

struct TodoListRow_Previews: PreviewProvider {
    static var previews: some View {
        let todoClient = TodoClient.preview
        let todos = todoClient.samples
        let todo1 = todos[0]
        let todo2 = todos[1]

        return Group {
            TodoListRow(
                viewModel: .init(
                    todo: todo1,
                    todoClient: todoClient,
                    editMode: .inactive
                )
            )
            .previewLayout(.fixed(width: 300, height: 100))
            .padding(12)

            TodoListRow(
                viewModel: .init(
                    todo: todo2,
                    todoClient: todoClient,
                    editMode: .inactive
                )
            )
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewLayout(.fixed(width: 300, height: 100))
            .padding(12)

            TodoListRow(
                viewModel: .init(
                    todo: todo1,
                    todoClient: todoClient,
                    editMode: .inactive
                )
            )
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 100))
            .padding(12)

            TodoListRow(
                viewModel: .init(
                    todo: todo2,
                    todoClient: todoClient,
                    editMode: .inactive
                )
            )
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 100))
            .padding(12)
        }
    }
}

#endif
