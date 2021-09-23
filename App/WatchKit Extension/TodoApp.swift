//
//  TodoApp.swift
//  TodoApp
//
//  Created by gonzoooooo on 2021/09/18.
//  
//

import SwiftUI

@main
struct TodoApp: App {
    @WKExtensionDelegateAdaptor
    private var appDelegate: ExtensionDelegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "TodoApp")
    }
}
