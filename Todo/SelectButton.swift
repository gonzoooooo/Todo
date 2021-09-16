//
//  SelectButton.swift
//  SelectButton
//
//  Created by gonzoooooo on 2021/09/09.
//

import SwiftUI

public enum SelectMode {
    case active
    case inactive

    public var isActive: Bool {
        self == .active
    }

    mutating public func toggle() {
        self = self.isActive ? .inactive : .active
    }
}

public struct SelectButton: View {
    @Binding var mode: SelectMode

    public var action: () -> Void

    public init(mode: Binding<SelectMode>, action: @escaping () -> Void = {}) {
        self._mode = mode
        self.action = action
    }

    public var body: some View {
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
            ForEach(["en-US", "ja-JP"], id: \.self) { lang in
                SelectButton(mode: .constant(.active))
                    .environment(\.locale, Locale(identifier: lang))
                    .previewLayout(.fixed(width: 320, height: 44))

                SelectButton(mode: .constant(.inactive))
                    .environment(\.locale, Locale(identifier: lang))
                    .previewLayout(.fixed(width: 320, height: 44))
                }
            }
    }
}
