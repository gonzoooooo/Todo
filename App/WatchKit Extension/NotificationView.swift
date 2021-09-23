//
//  NotificationView.swift
//  TodoApp
//
//  Created by gonzoooooo on 2021/09/18.
//  
//

import SwiftUI

struct NotificationView: View {
    var title: String?
    var message: String?

    var body: some View {
        Text(title ?? "Unknown Todo")
            .font(.headline)

        Divider()

        if let message = message {
            Text(message)
                .font(.caption)
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(
            title: "Study SwiftUI",
            message: "Launch Xcode and open my project."
        )
    }
}
