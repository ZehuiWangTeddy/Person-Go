import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "Chat"
    @AppStorage("isFaceIDOrTouchIDEnabled") var isFaceIDOrTouchIDEnabled: Bool = false
    @State private var isUnlocked = false
    @StateObject private var appLockManager = AppLockManager()
    @StateObject private var userAuth = UserAuth()
    @StateObject private var friendManager = FriendManager()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        Group {
            if appLockManager.isUnlocked || !isFaceIDOrTouchIDEnabled {
                TabView(selection: $selectedTab) {
                    ChatsView()
                        .tabItem {
                            Image(systemName: "message")
                            Text("Chat")
                        }
                        .tag("Chat")
                    MapView(mapViewRepresentable: MapViewRepresentable(locationManager: locationManager))
                    .tabItem {
                            Image(systemName: "map")
                            Text("Map")
                        }
                        .tag("Map")
                    InventoryView(friendManager: friendManager)
                        .tabItem {
                            Image(systemName: selectedTab == "Inventory" ? "door.garage.open" : "door.garage.closed")
                            Text("Inventory")
                        }
                        .tag("Inventory")
                    SettingView()
                        .environmentObject(userAuth)
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Setting")
                        }
                        .tag("Setting")
                }
                .onAppear() {
                    UITabBar.appearance().backgroundColor = UIColor(named: "Background")
                    UITabBar.appearance().unselectedItemTintColor = UIColor(named: "Secondary")
                }
                .tint(Color("Primary"))
            } else {
                AuthenticationView(isUnlocked: $appLockManager.isUnlocked)
            }
        }
        .environmentObject(appLockManager)
            .onAppear {
                if isFaceIDOrTouchIDEnabled {
                    appLockManager.isUnlocked = false
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
