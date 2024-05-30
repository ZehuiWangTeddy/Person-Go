import SwiftUI
import Supabase
import MapKit

struct InventoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSize: String? = nil // State to track selected size
    @State private var navigateToLaunchListView = false // State to trigger navigation
    @State private var navigateToMissileMapView = false // State to trigger navigation to missile map view
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    @State private var inventory: Inventory? // State to store the fetched inventory data

    let missileData = [
        ("Quickstrike", "5km"),
        ("Blaze Rocket", "10km"),
        ("Phoenix Inferno", "50km")
    ]

    var body: some View {
        NavigationStack { // Use NavigationStack instead of NavigationView
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
                        ForEach(missileData, id: \.0) { missile, range in
                            HStack {
                                Image(systemName: "missile")
                                    .rotationEffect(.degrees(-45))
                                    .foregroundColor(Color("Text"))
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
                    .disabled(selectedSize == nil)
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
            .navigationDestination(isPresented: $navigateToLaunchListView) {
                LaunchListView(selectedTab: $selectedTab, selectedFriendsStore: selectedFriendsStore, selectedSize: selectedSize)
            }
            .navigationDestination(isPresented: $navigateToMissileMapView) {
                MissileMapView()
            }
            .onAppear {
                Task {
                    inventory = await fetchInventory(for: UUID(uuidString: user_id)!)
                }
            }
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
}
