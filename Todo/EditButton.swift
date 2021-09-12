//
//  EditButton.swift
//  EditButton
//
//  Created by gonzoooooo on 2021/09/09.
//

import SwiftUI

struct EditButton: View {
    @Binding var editMode: EditMode

    var action: () -> Void = {}

    var body: some View {
        Button(role: role) {
            withAnimation {
                if editMode == .active {
                    action()
                    editMode = .inactive
                } else {
                    editMode = .active
                }
            }
        } label: {
            if editMode == .active {
                Text("Cancel")
                    .bold()
            } else {
                Text("Edit")
            }
        }
    }

    private var role: ButtonRole? {
        editMode == .active ? .cancel : nil
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditButton(editMode: .constant(.active))
                .previewLayout(.fixed(width: 320, height: 44))

            EditButton(editMode: .constant(.inactive))
                .previewLayout(.fixed(width: 320, height: 44))
        }
    }
}
