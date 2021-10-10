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
    let todoClient = TodoClient.shared

    var body: some View {
        WatchTodoListView(viewModel: .init(todoClient: todoClient))
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
