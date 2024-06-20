import SwiftUI
import CoreLocation

struct Friend1: Identifiable {
    public let id = UUID()
    var friendId: UUID?
    var name: String
    var distance: Double
    var avatar: String // Assume this is the name of an image in Assets.xcassets
}

struct LaunchListView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var friends: [Friend1] = []
    @State private var selectedFriend: UUID?
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    var selectedSize: String?
    @EnvironmentObject var userAuth: UserAuth
    @State private var showingAlert = false
    @State private var message = ""
    
    var user_id: String {
        return userAuth.user!.id.uuidString
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Friend List")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                Divider()
                List(friends, id: \.id) { friend in
                    FriendRow(friend: friend, isSelected: self.selectedFriend == friend.id)
                        .onTapGesture {
                            if self.selectedFriend == friend.id {
                                self.selectedFriend = nil
                            } else {
                                self.selectedFriend = friend.id
                            }
                        }
                        .listRowBackground(Color("Background"))
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    Task {
                        await loadFriends()
                    }
                }
                .onAppear {
                    Task {
                        await loadFriends()
                    }
                }
                
                Button(action: {
                    confirmAction()
                }) {
                    Text("Send Missile")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedFriend != nil ? Color("Primary") : Color("Primary").opacity(0.5))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                }
                .disabled(selectedFriend == nil)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Failed to launch missile"), message: Text(message), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
            .background(Color("Background"))
            .foregroundColor(Color("Text"))
        }
    }
    
    private func confirmAction() {
        let selected = friends.filter {
            selectedFriend == $0.id
        }
        
        for friend in selected {
            Task {
                // Fetch the current inventory
                let currentInventory = await fetchInventory(for: UUID(uuidString: user_id)!)
                
                // Check if the selected missile type is not zero
                let missileCount: Int
                switch selectedSize {
                case "Quickstrike":
                    missileCount = currentInventory?.small ?? 0
                case "Blaze Rocket":
                    missileCount = currentInventory?.medium ?? 0
                case "Phoenix Inferno":
                    missileCount = currentInventory?.large ?? 0
                default:
                    missileCount = 0
                }
                
                if missileCount > 0 {
                    let launchSuccess = await insertLaunch(user_id: UUID(uuidString: user_id)!, target_id: friend.friendId!, launch_type: selectedSize ?? "Phoenix Inferno")
                    let inventorySuccess = await decreaseInventory(for: UUID(uuidString: user_id)!, missileType: selectedSize ?? "Phoenix Inferno")
                    if launchSuccess && inventorySuccess {
                        selectedFriendsStore.friends = selected
                        selectedFriendsStore.selectedSize = selectedSize
                        DispatchQueue.main.async {
                            selectedFriendsStore.friends = selected
                        }
                        selectedTab = "Map"
                    } else {
                        DispatchQueue.main.async {
                            message = "An error occurred while launching the missile. Please try again."
                            showingAlert = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        message = "You do not have enough missiles to launch. Please get more missiles. Go to Add missile page to get more missiles"
                        showingAlert = true
                    }
                }
            }
        }
    }
    
    private func loadFriends() async {
        do {
            // Fetch the friends list
            let friendsList: [FriendsForMap] = try await fetchFriendsForMap(for: UUID(uuidString: user_id)!)!
            
            // Clear the existing friends list
            friends.removeAll()
            
            // For each friend in the list, calculate the distance from the user's current location
            for friend in friendsList {
                if let friend_id = friend.friend_id {
                    if let latitude = friend.latitude, let longitude = friend.longitude {
                        let friendLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = locationManager.calculateDistance(from: locationManager.currentLocation!, to: friendLocation)
                        
                        // Create a new Friend1 object with the calculated distance and add it to the friends array
                        let newFriend = Friend1(friendId: friend_id, name: friend.username ?? "", distance: distance, avatar: friend.avatar_url ?? "sample")
                        friends.append(newFriend)
                    }
                } else {
                    print("friendId is nil for friend with username: \(friend.username ?? "Unknown")")
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
                    .padding()
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(Color("Text"))
                Spacer()
                Text("\(friend.distance, specifier: "%.1f") km")
                    .font(.subheadline)
                    .foregroundColor(Color("Text"))
                    .padding()
            }
            .background(isSelected ? Color("Primary").opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
    }
}

class SelectedFriends: ObservableObject {
    @Published var friends: [Friend1] = []
    @Published var selectedSize: String?
}
