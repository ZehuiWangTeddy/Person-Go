import SwiftUI

struct LaunchListView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFriends: Set<UUID> = []
    @State var friendManager: FriendManager
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack {
                List(friendManager.friends, id: \.id) { friend in
                    FriendRow(friend: friend, isSelected: self.selectedFriends.contains(friend.id))
                        .onTapGesture {
                            if self.selectedFriends.contains(friend.id) {
                                self.selectedFriends.remove(friend.id)
                            } else {
                                self.selectedFriends.insert(friend.id)
                            }
                        }
                        .listRowBackground(Color("Background"))
                }
                .listStyle(PlainListStyle()) // Ensures the list style is consistent with the app's design
                
                Button(action: {
                    confirmAction()
                }) {
                    Text("Send Missile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Friend List")
        .foregroundColor(Color("Text"))
       
    }

    private func confirmAction() {
        // Perform the action with selected friends
        let selected = friendManager.friends.filter { selectedFriends.contains($0.id) }
        print("Selected friends: \(selected.map { $0.name })")
        // Add your action here
    }
}

struct FriendRow: View {
    let friend: Friend
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(friend.avatar)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            
            VStack(alignment: .leading) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(Color("Text"))
            }
            Spacer() // Pushes the distance to the right
            Text("\(friend.distance, specifier: "%.1f") km")
                .font(.subheadline)
                .foregroundColor(Color("Text"))
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(isSelected ? Color("Primary").opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct LaunchListView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchListView(friendManager: FriendManager())
            .environmentObject(UserAuth())
    }
}
