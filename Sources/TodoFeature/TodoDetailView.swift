import CoreDataModels
import SwiftUI

@available(iOS 15, *)
struct TodoDetailView: View {
    @Environment(\.presentationMode)
    private var presentationMode

    @ObservedObject
    private var viewModel: TodoDetailViewModel

    init(viewModel: TodoDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section {
                TextField("Task Name", text: $viewModel.name, prompt: Text("Task Name"))
            }

            Section {
                Toggle("Notification", isOn: $viewModel.isNotified.animation())

                if viewModel.isNotified {
                    HStack(spacing: 0) {
                        // FIXME: DatePicker が右端に配置されないためのワークアラウンド
                        Spacer()
                            .frame(maxWidth: .infinity)

                        DatePicker(
                            "",
                            selection: $viewModel.notifiedDate,
                            displayedComponents: .date
                        )

                        DatePicker(
                            "",
                            selection: $viewModel.notifiedDate,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }

            Section {
                HStack {
                    Toggle(isOn: $viewModel.isFlagged) {
                        Text("Flag")
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    viewModel.presentedConfirmationForRemoveTask.toggle()
                } label: {
                    Text("Remove Task")
                        .foregroundColor(.systemRed)
                }
            }
        }
        .confirmationDialog(
            Text("Remove Task"),
            isPresented: $viewModel.presentedConfirmationForRemoveTask
        ) {
            Button(role: .destructive) {
                Task {
                    await viewModel.delete()
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Remove task")
            }
            Button(role: .cancel) {
                viewModel.presentedConfirmationForRemoveTask = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        do {
                            try await viewModel.update()
                        } catch {
                            print("error: \(error)")
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Done")
                        .bold()
                }
                .disabled(viewModel.isDisabledRegisterButton)
            }

            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

#if DEBUG

import DatabaseClients
import NotificationClient

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let todoClient = TodoClient.preview
        let notificationClient = NotificationClient.shared
        let todo = TodoClient.preview.samples.first!

        return Group {
            NavigationView {
                TodoDetailView(
                    viewModel: .init(
                        todo: todo,
                        todoClient: todoClient,
                        notificationClient: notificationClient
                    )
                )
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

             NavigationView {
                TodoDetailView(
                    viewModel: .init(
                        todo: todo,
                        todoClient: todoClient,
                        notificationClient: notificationClient
                    )
                )
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoDetailView(
                    viewModel: .init(
                        todo: todo,
                        todoClient: todoClient,
                        notificationClient: notificationClient
                    )
                )
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}

#endif
