import SwiftUI

struct FriendsListView: View {
    @State private var selectedFriends: Set<UUID> = []
    @State var friends: [Friend] = [
        Friend(name: "Joe", distance: 1.5),
        Friend(name: "JJJ", distance: 1.8),
        Friend(name: "www", distance: 2.5),
        Friend(name: "SSS", distance: 2.8),
        Friend(name: "TTT", distance: 3.5)
    ]
    
    var body: some View {
        NavigationView {
            List(friends, id: \.id, selection: $selectedFriends) { friend in
                HStack {
                    VStack(alignment: .leading) {
                        Text(friend.name)
                            .font(.headline)
                        Text("\(friend.distance, specifier: "%.1f") km")
                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Launch List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: confirmSelection) {
                        Text("Confirm")
                    }
                }
            }
        }
    }
    
    func confirmSelection() {
        print("Selected Friends: \(selectedFriends)")
        // Implement the action you want to perform with the selected friends.
    }
}

struct FriendsListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsListView()
    }
}
