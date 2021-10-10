import SwiftUI

@available(watchOS 8, *)
struct WatchTodoListRow: View {
    let viewModel: WatchTodoListRowViewModel

    var body: some View {
        Button {
            viewModel.handleToggleComplete()
        } label: {
            HStack {
                Image(systemName: viewModel.checkImageName)

                VStack(alignment: .leading) {
                    Text(viewModel.name)
                        .foregroundColor(viewModel.foregroundColorForName)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    Spacer(minLength: 8)
                }

                Spacer()
            }
        }
    }
}
