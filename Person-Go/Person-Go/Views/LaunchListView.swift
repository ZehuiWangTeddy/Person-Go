import SwiftUI

struct LaunchListView: View {
    @State private var friends: [Friend] = [
        Friend(name: "Joe", distance: 1.5, avatar: "userprofile"),
        Friend(name: "JJJ", distance: 1.8, avatar: "userprofile"),
        Friend(name: "WWW", distance: 2.5, avatar: "userprofile"),
        Friend(name: "SSS", distance: 2.8, avatar: "userprofile"),
        Friend(name: "TTT", distance: 3.5, avatar: "userprofile")
    ]
    @State private var selectedFriends: Set<UUID> = []

    var body: some View {
        VStack {
            List(friends) { friend in
                FriendRow(friend: friend, isSelected: self.selectedFriends.contains(friend.id))
                    .onTapGesture {
                        if self.selectedFriends.contains(friend.id) {
                            self.selectedFriends.remove(friend.id)
                        } else {
                            self.selectedFriends.insert(friend.id)
                        }
                    }
            }
            
            Button(action: {
                confirmAction()
            }) {
                Text("Confirm")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .navigationTitle("List")
    }

    private func confirmAction() {
        // Perform the action with selected friends
        let selected = friends.filter { selectedFriends.contains($0.id) }
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
            }
            Spacer() // Pushes the distance to the right
            Text("\(friend.distance, specifier: "%.1f") km")
                .font(.subheadline)
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct LaunchListView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchListView()
    }
}

