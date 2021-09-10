//
//  SelectButton.swift
//  SelectButton
//
//  Created by gonzoooooo on 2021/09/09.
//

import SwiftUI

enum SelectMode {
    case active
    case inactive

    var isActive: Bool {
        self == .active
    }

    mutating func toggle() {
        self = self.isActive ? .inactive : .active
    }
}

struct SelectButton: View {
    @Binding var mode: SelectMode

    var action: () -> Void = {}

    var body: some View {
        Button {
            withAnimation {
                mode.toggle()
                action()
            }
        } label: {
            Text(mode.isActive ? "Deselect All" : "Select All")
        }
    }
}

struct SelectButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectButton(mode: .constant(.active))
                .previewLayout(.fixed(width: 320, height: 44))

            SelectButton(mode: .constant(.inactive))
                .previewLayout(.fixed(width: 320, height: 44))
        }
    }
}
