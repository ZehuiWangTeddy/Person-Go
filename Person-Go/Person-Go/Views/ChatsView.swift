import SwiftUI

struct ChatsView: View {
    @State private var showFriendProfile = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    self.showFriendProfile = true
                }) {
                    Text("Friend's Name")
                        .foregroundColor(.primary) // Not tinted
                }
                .padding()

                NavigationLink(destination: FriendProfileView(), isActive: $showFriendProfile) {
                    EmptyView()
                }
            }
            .navigationBarTitle("Chats", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: AddFriendsView()) {
                    Image(systemName: "plus")
                }
            )
        }
    }
}