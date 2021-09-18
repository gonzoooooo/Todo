//
//  File.swift
//  
//
//  Created by gonzoooooo on 2021/09/18.
//  
//

import CoreDataModels
import SwiftUI

public struct TodoMenuView: View {
    @State
    private var selection: Int? = 0

    public var persistenceController: PersistenceController

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    public var body: some View {
        List {
            NavigationLink(tag: 0, selection: $selection) {
                TodoListView(defaultNavigationTitle: String(localized: "All"))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } label: {
                HStack {
                    Image(systemName: "tray.full.fill")
                        .foregroundColor(.systemGray)
                        .font(.title2)
                        .frame(width: 44)

                    Text("All")
                }
            }

            NavigationLink(tag: 1, selection: $selection) {
                TodoListView(isHiddenUnflaggedTodos: true, defaultNavigationTitle: String(localized: "Flagged"))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } label: {
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                        .frame(width: 44)

                    Text("Flagged")
                }
            }
        }
        .navigationTitle("Todo")
    }
}

struct TodoMenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TodoMenuView(persistenceController: .preview)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoMenuView(persistenceController: .preview)
                    .preferredColorScheme(.dark)
            }
            .environment(\.locale, Locale(identifier: "ja-JP"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
            .previewDisplayName("iPhone 12 Mini")

            NavigationView {
                TodoMenuView(persistenceController: .preview)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}
