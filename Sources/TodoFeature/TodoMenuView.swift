import CoreDataModels
import SwiftUI

@available(iOS 15, *)
public struct TodoMenuView: View {
    @State
    private var selection: Int? = 0

    @ObservedObject
    private var viewModel: TodoMenuViewModel

    public init(viewModel: TodoMenuViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            NavigationLink(tag: 0, selection: $selection) {
                TodoListView(viewModel: viewModel.todoListViewModel(buttonType: .all))
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
                TodoListView(viewModel: viewModel.todoListViewModel(buttonType: .flagged))
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

#if DEBUG

import DatabaseClients
import NotificationClient

struct TodoMenuView_Previews: PreviewProvider {
   static var previews: some View {
       let todoProvider = TodoProvider.preview
       let notificationClient = NotificationClient.shared
       let viewModel = TodoMenuViewModel(todoProvider: todoProvider, notificationClient: notificationClient)

       Group {
           NavigationView {
               TodoMenuView(viewModel: viewModel)
           }
           .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
           .previewDisplayName("iPhone 12 Mini")

           NavigationView {
               TodoMenuView(viewModel: viewModel)
                   .preferredColorScheme(.dark)
           }
           .environment(\.locale, Locale(identifier: "ja-JP"))
           .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
           .previewDisplayName("iPhone 12 Mini")

           NavigationView {
               TodoMenuView(viewModel: viewModel)
           }
           .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
           .previewDisplayName("iPhone 12 Pro Max")
       }
   }
}

#endif
