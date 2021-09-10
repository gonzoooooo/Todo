//
//  TodoApp.swift
//  Todo
//
//  Created by gonzoooooo on 2021/09/03.
//

import SwiftUI

@main
struct TodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .tint(.accentColor)
        }
    }
}
