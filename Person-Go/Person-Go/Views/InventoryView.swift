import SwiftUI
import Supabase

struct InventoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSize: String? = nil // State to track selected size
    @State private var navigateToLaunchListView = false // State to trigger navigation
    @Binding var selectedTab: String
    @ObservedObject var selectedFriendsStore: SelectedFriends
    @State private var inventory: Inventory? // State to store the fetched inventory data

    var body: some View {
        NavigationStack { // Use NavigationStack instead of NavigationView
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Inventory")
                            .font(.system(size: 30)) // Increased font size
                            .fontWeight(.bold)
                            .padding(.bottom)
                        Divider()
                            .frame(height: 2) // Increase the height to make the divider thicker
                    }
                    .padding(.bottom, 90) // Apply padding only to the bottom
                    .padding(.horizontal) // Add horizontal padding

                    VStack(alignment: .leading) {
                        ForEach(["Small", "Medium", "Large"], id: \.self) { size in
                            HStack {
                                Image(systemName: "missile")
                                    .rotationEffect(.degrees(-45))
                                Text(size)
                                    .font(.system(size: 25))
                                Spacer() // Pushes the number to the right
                                Text("\(inventoryValue(for: size))") // Replace with actual number
                                    .font(.system(size: 25))
                            }
                            .padding()
                            .background(self.selectedSize == size ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                self.selectedSize = size
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal) // Add horizontal padding

                    Button(action: {
                        if selectedSize != nil {
                            navigateToLaunchListView = true
                        }
                    }) {
                        Text("Launch")
                            .font(.title)
                            .padding()
                            .background(selectedSize != nil ? Color(hexString: "#EC9583") : Color.gray) // Change the background color to #EC9583 if size is selected, else gray
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 80) // Add some space above the button
                    .disabled(selectedSize == nil) // Disable the button if no size is selected

                    Spacer() // Pushes the VStack to the top
                }
            }
            .background(colorScheme == .light ? Color(hexString: "#F3EBD8") : Color(hexString: "#271F0C")) // Change the background color based on the color scheme
            .navigationBarHidden(true) // Hide the navigation bar
            .navigationDestination(isPresented: $navigateToLaunchListView) {
                LaunchListView(selectedTab: $selectedTab, selectedFriendsStore: selectedFriendsStore, selectedSize: selectedSize)
            }
            .onAppear {
                Task {
//                    let inventoryInstance = Inventory(userID: UUID(uuidString: user_id)!, small: 0, medium: 0, large: 0)
                    inventory = await fetchInventory(for: UUID(uuidString: user_id)!)
                }
            }
        }
    }

    private func inventoryValue(for size: String) -> Int {
        switch size {
        case "Small":
            return inventory?.small ?? 0
        case "Medium":
            return inventory?.medium ?? 0
        case "Large":
            return inventory?.large ?? 0
        default:
            return 0
        }
    }
}
