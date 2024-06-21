import SwiftUI
import Supabase
import MapKit
import SDWebImageSwiftUI

struct InventoryView: View {
    @State private var selectedSize: String? = nil
    @State private var navigateToLaunchListView = false
    @State private var navigateToTaskView = false // Updated to reflect the new view
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    @State private var inventory: Inventory? // State to store the fetched inventory data
    @EnvironmentObject var userAuth: UserAuth
    @State private var navigateToMissileMapView = false
    
    var user_id: String {
        return userAuth.user!.id.uuidString
    }
    
    let missileData = [
        ("Quickstrike", "100m", "quickstrike.gif"),
        ("Blaze Rocket", "500m", "blaze_rocket.gif"),
        ("Phoenix Inferno", "1km", "phoenix_inferno.gif")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Inventory")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    Button(action: {
                        navigateToMissileMapView = true
                    }) {
                        Text("Add Missile")
                            .foregroundColor(Color("Primary"))
                    }
                }
                Divider()
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(missileData, id: \.0) { missile, range, imageName in
                            HStack {
                                missileImage(imageName: imageName)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .padding()
                                VStack(alignment: .leading) {
                                    Text(missile)
                                        .font(.title2)
                                    Text("Impact Range: \(range)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(inventoryValue(for: missile))")
                                    .font(.title2)
                                    .foregroundColor(Color("Text"))
                                    .padding()
                            }
                            .background(self.selectedSize == missile ? Color("Primary").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                self.selectedSize = missile
                            }
                            .contentShape(Rectangle())
                            Divider()
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToLaunchListView) {
                    LaunchListView(selectedTab: $selectedTab, selectedFriendsStore: selectedFriendsStore, selectedSize: selectedSize)
                }
                .navigationDestination(isPresented: $navigateToMissileMapView) {
                    TaskView()
                }
                .onAppear {
                    Task {
                        inventory = await fetchInventory(for: UUID(uuidString: user_id)!)
                    }
                }
                
                Button(action: {
                    if selectedSize != nil {
                        navigateToLaunchListView = true
                    }
                }) {
                    Text("Launch")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedSize != nil ? Color("Primary") : Color("Primary").opacity(0.5))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                }
                .disabled(selectedSize == nil || inventoryValue(for: selectedSize!) <= 0)
            }
            .padding()
            .background(Color("Background"))
            .foregroundColor(Color("Text"))
        }
    }
    
    private func inventoryValue(for size: String) -> Int {
        switch size {
        case "Quickstrike":
            return inventory?.small ?? 0
        case "Blaze Rocket":
            return inventory?.medium ?? 0
        case "Phoenix Inferno":
            return inventory?.large ?? 0
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
