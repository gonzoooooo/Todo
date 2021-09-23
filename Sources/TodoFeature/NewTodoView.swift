import CoreDataModels
import DatabaseClients
import NotificationClient
import NotificationHelper
import SwiftUI

@available(iOS 15, *)
struct NewTodoView: View {
    @Environment(\.presentationMode)
    private var presentationMode

    @Environment(\.managedObjectContext)
    private var viewContext

    @State
    var name = ""

    @State
    var isFlagged = false

    @State
    var isNotified = false

    @State
    var notifiedDate: Date = Date()

    var todoProvider: TodoProvider = .shared

    let notificationClient: NotificationClient = .shared

    private var isDisabledRegisterButton: Bool {
        return name.isEmpty
    }

    var body: some View {
        List {
            Section {
                TextField("Task Name", text: $name, prompt: Text("Task Name"))
            }

            Section {
                Toggle("Notification", isOn: $isNotified.animation())

                if isNotified {
                    HStack(spacing: 0) {
//                        Text("日時")

                        // FIXME: DatePicker が右端に配置されないためのワークアラウンド
                        Spacer()
                            .frame(maxWidth: .infinity)

                        DatePicker(
                            "",
                            selection: $notifiedDate,
                            displayedComponents: .date
                        )

                        DatePicker(
                            "",
                            selection: $notifiedDate,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }

            Section {
                Toggle(isOn: $isFlagged) {
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
                        await register()
                    }
                } label: {
                    Text("Add")
                        .bold()
                }
                .disabled(isDisabledRegisterButton)
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

    private func register() async {
        do {
            let id = UUID()

            try await todoProvider.add(
                id: id,
                name: name,
                notifiedDate: isNotified ? notifiedDate : nil,
                isFlagged: isFlagged
            )

            if isNotified {
                notificationClient.register(
                    identifier: id,
                    name: name,
                    date: notifiedDate
                )
            }

            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error: \(error)")
        }
    }
}

struct NewTodoView_Previews: PreviewProvider {
    static var previews: some View {
        let todoProvider = TodoProvider.preview

        return Group {
            NavigationView {
                NewTodoView(todoProvider: todoProvider)
                    .environment(\.managedObjectContext, todoProvider.persistence.container.viewContext)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))

            NavigationView {
                NewTodoView(name: "Study SwiftUI", isNotified: true, notifiedDate: Date())
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))

            NavigationView {
                NewTodoView()
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))

            NavigationView {
                NewTodoView(name: "Study SwiftUI", isNotified: true, notifiedDate: Date())
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
        }
    }
}
