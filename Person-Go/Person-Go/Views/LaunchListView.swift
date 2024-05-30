import SwiftUI
import CoreLocation

struct Friend1: Identifiable {
    public let id = UUID()
    var name: String
    var distance: Double
    var avatar: String // Assume this is the name of an image in Assets.xcassets
}

struct LaunchListView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var friends: [Friend1] = []
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFriends: Set<UUID> = []
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    var selectedSize: String?

    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Text("Friend List")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("Text"))
                    .padding(.bottom, 0)
                
                Divider()
                    .frame(height: 2)
                
                List(friends, id: \.id) { friend in
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
                .refreshable {
                    await loadFriends()
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                    confirmAction()
                }) {
                    Text("Send Missile")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedFriends.isEmpty ? Color.gray : Color("Primary"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(10)
                }
                .padding(.top, 40)
                .disabled(selectedFriends.isEmpty)
            }
            .padding()
            .background(Color("Background"))
            .foregroundColor(Color("Text"))
            .onAppear {
                Task {
                    await loadFriends()
                }
            }
        }
        .background(Color("Background")) // Ensuring the background color is consistent
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
        do {
            // Fetch the friends list
            let friendsList: [FriendsForMap] = try await fetchFriendsForMap(for: UUID(uuidString: user_id)!)!

            // Clear the existing friends list
            friends.removeAll()

            // For each friend in the list, calculate the distance from the user's current location
            for friend in friendsList {
                if let latitude = friend.latitude, let longitude = friend.longitude {
                    let friendLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = locationManager.calculateDistance(from: locationManager.currentLocation!, to: friendLocation)

                    // Create a new Friend1 object with the calculated distance and add it to the friends array
                    let newFriend = Friend1(name: friend.username ?? "", distance: distance, avatar: friend.avatarUrl ?? "sample")
                    friends.append(newFriend)
                }
            }
        } catch {
            print("Failed to load friends: \(error)")
        }
    }

    struct FriendRow: View {
        let friend: Friend1
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
}

class SelectedFriends: ObservableObject {
    @Published var friends: [Friend1] = []
    @Published var selectedSize: String?
}
