import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "Chat"
    @AppStorage("isFaceIDOrTouchIDEnabled") var isFaceIDOrTouchIDEnabled: Bool = false
    @State private var isUnlocked = false
    @StateObject private var appLockManager = AppLockManager()
    @StateObject private var selectedFriendsStore = SelectedFriends()
    
    @EnvironmentObject var userAuth: UserAuth
    
    var body: some View {
        Group {
            if appLockManager.isUnlocked || !isFaceIDOrTouchIDEnabled {
                TabView(selection: $selectedTab) {
                    ChatsView()
                        .environmentObject(userAuth)
                        .tabItem {
                            Image(systemName: "message")
                            Text("Chat")
                        }
                        .tag("Chat")
                    MapView(selectedFriendsStore: selectedFriendsStore)
                        .tabItem {
                            Image(systemName: "map")
                            Text("Map")
                        }
                        .tag("Map")
                    InventoryView(selectedTab: $selectedTab, selectedFriendsStore: selectedFriendsStore)
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
                    UITabBar.appearance().backgroundColor = UIColor(Color("Background"))
                    UITabBar.appearance().unselectedItemTintColor = UIColor(Color("Secondary"))
                }
                .tint(Color("Primary"))
            } else {
                AuthenticationView(isUnlocked: $appLockManager.isUnlocked)
            }
        }
        .environmentObject(appLockManager)
        .environmentObject(userAuth)
        .onAppear{
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
