//
//  ContentView.swift
//  TodoApp
//
//  Created by gonzoooooo on 2021/09/18.
//  
//

import DatabaseClients
import SwiftUI
import WatchFeature

struct ContentView: View {
    let todoProvider = TodoProvider.shared

    var body: some View {
        WatchTodoListView(todoProvider: todoProvider)
            .environment(\.managedObjectContext, todoProvider.persistence.container.viewContext)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 40mm"))
        }
    }
}
