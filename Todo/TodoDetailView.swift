//
//  TodoDetailView.swift
//  TodoDetailView
//
//  Created by gonzoooooo on 2021/09/03.
//

import CoreData
import SwiftUI

struct TodoDetailView: View {
    @Environment(\.presentationMode)
    private var presentationMode

    var id: UUID

    @State
    var name: String

    @State
    var isCompleted: Bool

    @State
    var isNotified: Bool

    @State
    var notifiedDate: Date

    @State
    var isFlagged: Bool

    var todoProvider: TodoProvider = .shared

    let notificationClient: NotificationClient = .shared

    private var isDisabledRegisterButton: Bool {
        return name.isEmpty
    }

    var body: some View {
        List {
            Section {
                TextField("タスク名", text: $name, prompt: Text("た"))
            }

            Section {
                Toggle("通知", isOn: $isNotified.animation())

                if isNotified {
                    HStack(spacing: 0) {
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
                HStack {
                    Toggle(isOn: $isFlagged) {
                        Text("フラグを立てる")
                    }
                }
            }
        }
        .navigationTitle("タスク")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        do {
                            try await update()
                        } catch {
                            print("error: \(error)")
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("登録")
                }
                .disabled(isDisabledRegisterButton)
            }

            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("キャンセル")
                }
            }
        }
    }

    private func update() async throws {
        try await todoProvider.update(
            id: id,
            name: name,
            isCompleted: isCompleted,
            notifiedDate: isNotified ? notifiedDate : nil,
            isFlagged: isFlagged
        )

        notificationClient.cancel(id: id.uuidString)

        if isNotified {
            notificationClient.register(identifier: id, name: name, date: notifiedDate)
        }
    }
}

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let todo = TodoProvider.preview.samples.first!

        return Group {
            NavigationView {
                TodoDetailView(
                    id: todo.id,
                    name: todo.name,
                    isCompleted: todo.isCompleted,
                    isNotified: true,
                    notifiedDate: Date(),
                    isFlagged: todo.isFlagged
                )
                .environment(\.locale, Locale(identifier: "ja-JP"))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoDetailView(
                    id: todo.id,
                    name: todo.name,
                    isCompleted: todo.isCompleted,
                    isNotified: true,
                    notifiedDate: Date(),
                    isFlagged: todo.isFlagged
                )
                .environment(\.locale, Locale(identifier: "ja-JP"))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}
