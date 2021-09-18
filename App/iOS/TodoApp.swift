//
//  TodoApp.swift
//  Todo
//
//  Created by gonzoooooo on 2021/09/03.
//

import AppFeature
import CoreDataModels
import SwiftUI
import TodoFeature
import UIKit

@main
struct TodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    TodoMenuView(persistenceController: persistenceController)
                } else {
                    TodoListView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .tint(.accentColor)
        }
    }
}
