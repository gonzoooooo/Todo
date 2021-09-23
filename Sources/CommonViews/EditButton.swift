import SwiftUI

@available(iOS 15, *)
public struct EditButton: View {
    @Binding var editMode: EditMode

    public var action: () -> Void

    public init(editMode: Binding<EditMode>, action: @escaping () -> Void = {}) {
        self._editMode = editMode
        self.action = action
    }

    public var body: some View {
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
