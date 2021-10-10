//
//  TodoApp.swift
//  Todo
//
//  Created by gonzoooooo on 2021/09/03.
//

import AppFeature
import CoreDataModels
import DatabaseClients
import NotificationClient
import SwiftUI
import TodoFeature
import UIKit

@main
struct TodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    let todoProvider = TodoProvider.shared
    let notificationClient = NotificationClient.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    TodoMenuView(
                        viewModel: .init(
                            todoProvider: todoProvider,
                            notificationClient: notificationClient
                        )
                    )
                } else {
                    TodoListView(
                        viewModel: .init(
                            todoProvider: todoProvider,
                            notificationClient: notificationClient
                        )
                    )
                }
            }
            .tint(.accentColor)
        }
    }
}
