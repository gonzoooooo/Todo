//
//  TodoListRow.swift
//  TodoListRow
//
//  Created by gonzoooooo on 2021/09/03.
//

import SwiftUI

struct TodoListRow: View {
    @Environment(\.editMode)
    var editMode

    @ObservedObject
    var todo: Todo

    var checkTapAction: () -> Void = {}
    var flagTapAction: () -> Void

    private var foregroundColorForName: Color {
        todo.isCompleted ? .secondary : .primary
    }

    var body: some View {
        HStack {
            Button(action: checkTapAction) {
                if todo.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                }
            }
            .disabled(editMode?.wrappedValue == .active)

            VStack(alignment: .leading) {
                Text(todo.name)
                    .foregroundColor(foregroundColorForName)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                if let notifiedDate = todo.notifiedDate {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.systemRed)
                        Text(dateString(from: notifiedDate))
                            .font(.caption)
                            .foregroundColor(.systemRed)
                    }
                    .padding(.bottom, 4)
                }

                Text("Order: \(todo.order)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer(minLength: 8)
            }

            Spacer()

            Button {
                flagTapAction()
            } label: {
                if todo.isFlagged {
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
    }

    private func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: date)
    }
}

struct TodoListRow_Previews: PreviewProvider {
    static var previews: some View {
        let todos = TodoProvider.preview.samples
        let todo1 = todos[0]
        let todo2 = todos[1]

        return Group {
            TodoListRow(todo: todo1, flagTapAction: {})
                .previewLayout(.fixed(width: 300, height: 100))
                .padding(12)

            TodoListRow(todo: todo2, flagTapAction: {})
                .previewLayout(.fixed(width: 300, height: 100))
                .padding(12)

            TodoListRow(todo: todo1, flagTapAction: {})
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 300, height: 100))
                .padding(12)

            TodoListRow(todo: todo2, flagTapAction: {})
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 300, height: 100))
                .padding(12)
        }
    }
}
