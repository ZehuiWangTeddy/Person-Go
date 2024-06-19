import SwiftUI
import Supabase
import MapKit
import SDWebImageSwiftUI

struct InventoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSize: String? = nil
    @State private var navigateToLaunchListView = false
    @State private var navigateToTaskView = false // Updated to reflect the new view
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    @State private var inventory: Inventory? // State to store the fetched inventory data
    @EnvironmentObject var userAuth: UserAuth

    var user_id: String {
        return userAuth.user!.id.uuidString
    }

    @State private var inventory: UserInventory = UserInventory(small: 0, medium: 0, large: 0)
    @State private var userId: UUID? = nil // State to hold the user ID

    let missileData = [
        ("Quickstrike", "100m", "quickstrike.gif"),
        ("Blaze Rocket", "500m", "blaze_rocket.gif"),
        ("Phoenix Inferno", "1km", "phoenix_inferno.gif")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Inventory")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 0)
                            .foregroundColor(Color("Text"))
                    Divider()
                            .frame(height: 2)

                    VStack(alignment: .leading) {
                        ForEach(missileData, id: \.0) { missile, range, imageName in
                            HStack {
                                missileImage(imageName: imageName)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(.trailing, 8)
                                VStack(alignment: .leading) {
                                    Text(missile)
                                            .font(.title2)
                                            .foregroundColor(Color("Text"))
                                    Text("Impact Range: \(range)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(inventoryValue(for: missile))")
                                        .font(.title2)
                                        .foregroundColor(Color("Text"))
                            }
                                    .padding()
                                    .background(self.selectedSize == missile ? Color.gray.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        self.selectedSize = missile
                                    }
                            Divider()
                        }
                    }
                            .padding(.horizontal)

                    Button(action: {
                        if selectedSize != nil {
                            navigateToLaunchListView = true
                        }
                    }) {
                        Text("Launch")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedSize != nil ? Color("Primary") : Color.gray)
                                .foregroundColor(Color("Text"))
                                .cornerRadius(10)
                    }
                            .padding(.top, 40)
                            .disabled(selectedSize == nil || inventoryValue(for: selectedSize!) <= 0)
                }
                        .padding()
            }
                    .background(Color("Background"))
                    .navigationBarItems(trailing: Button(action: {
                        navigateToMissileMapView = true
                    }) {
                        Text("Add Missile")
                                .foregroundColor(Color("Primary"))
                    })
                    .navigationDestination(isPresented: $navigateToTaskView) {
                if let userId = userId {
                    TaskView(inventory: $inventory, userId: userId) // Pass userId to TestView
                } else {
                    Text("User ID not available") // Fallback if userId is not set
                }
            }
            .navigationDestination(isPresented: $navigateToLaunchListView) {
                LaunchListView(selectedTab: $selectedTab, selectedFriendsStore: selectedFriendsStore, selectedSize: selectedSize)
            }
                    .onAppear {
                        Task {
                             userId = userIdString
                        if let fetchedInventory = await fetchInventory(for: userIdString) {
                            inventory = UserInventory(small: fetchedInventory.small, medium: fetchedInventory.medium, large: fetchedInventory.large)
                        }
                        }
                    }
        }
    }

    private func inventoryValue(for size: String) -> Int {
        switch size {
        case "Quickstrike":
            return inventory.small
        case "Blaze Rocket":
            return inventory.medium
        case "Phoenix Inferno":
            return inventory.large
        default:
            return 0
        }
    }

    private func missileImage(imageName: String) -> some View {
        if let _ = Bundle.main.path(forResource: imageName, ofType: nil) {
            return AnyView(AnimatedImage(name: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit))
        } else {
            return AnyView(Text("Image not found")
                    .foregroundColor(.red)
                    .frame(width: 50, height: 50))
        }
    }
}
