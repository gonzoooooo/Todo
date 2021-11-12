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

    let todoClient = TodoClient.shared
    let notificationClient = NotificationClient.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    TodoMenuView(
                        viewModel: .init(
                            todoClient: todoClient,
                            notificationClient: notificationClient
                        )
                    )
                    TodoListView(viewModel: todoListViewModel)
                } else {
                    TodoListView(
                        viewModel: .init(
                            todoClient: todoClient,
                            notificationClient: notificationClient
                        )
                    )
                }
            }
            .tint(.accentColor)
        }
    }

    private var todoListViewModel: TodoListViewModel {
        return .init(
            todoClient: todoClient,
            notificationClient: notificationClient,
            defaultNavigationTitle: String(localized: "All")
        )
    }
}
