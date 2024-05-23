import SwiftUI
import CoreLocation

struct LaunchListView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var friends: [Friend] = []
    @State private var selectedFriends: Set<UUID> = []
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    var selectedSize: String?

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
                    .refreshable {
                        await loadFriends()
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
                .onAppear {
                    Task {
                        await loadFriends()
                    }
                }
    }

    private func confirmAction() {
        let selected = friends.filter { selectedFriends.contains($0.id) }
        print("Selected friends: \(selected.map { $0.name })")
        selectedFriendsStore.friends = selected
        selectedFriendsStore.selectedSize = selectedSize
        DispatchQueue.main.async {
            selectedFriendsStore.friends = selected
        }
        selectedTab = "Map"
    }

    private func loadFriends() async {
    friends = []
    let fetchedFriends = await fetchFriends(for: UUID(uuidString: user_id)!)
    let profiles = await fetchProfile()
    let locations = await fetchLocation()

    for fetchedFriend in fetchedFriends {
        if let profile = profiles.first(where: { $0.id == fetchedFriend.friendId }),
           let location = locations.first(where: { $0.userId == fetchedFriend.friendId }),
           let currentLocation = locationManager.currentLocation {
            let friendLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = locationManager.calculateDistance(from: currentLocation, to: friendLocation)
            let friend = Friend(name: profile.username ?? "No username", distance: distance, avatar: "userprofile")
            friends.append(friend)
        }
    }
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

class SelectedFriends: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var selectedSize: String?
}

