import CoreDataModels
import SwiftUI

@available(iOS 15, *)
struct NewTodoView: View {
    @Environment(\.presentationMode)
    private var presentationMode

    @ObservedObject
    var viewModel: NewTodoViewModel

    init(viewModel: NewTodoViewModel) {
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
//                        Text("日時")

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
                Toggle(isOn: $viewModel.isFlagged) {
                    Text("Flag")
                }
            }
        }
        .navigationTitle("New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.register()
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Add")
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

struct NewTodoView_Previews: PreviewProvider {
    static var previews: some View {
        let todoClient = TodoClient.preview
        let notificationClient = NotificationClient.shared

        return Group {
            NavigationView {
                NewTodoView(viewModel: .init(todoClient: todoClient, notificationClient: notificationClient))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))

            NavigationView {
                NewTodoView(viewModel: .init(todoClient: todoClient, notificationClient: notificationClient))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))

            NavigationView {
                NewTodoView(viewModel: .init(todoClient: todoClient, notificationClient: notificationClient))
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))

            NavigationView {
                NewTodoView(viewModel: .init(todoClient: todoClient, notificationClient: notificationClient))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
        }
    }
}

#endif
