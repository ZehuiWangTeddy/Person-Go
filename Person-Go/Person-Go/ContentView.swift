import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "Chat"

    var body: some View {
        TabView(selection: $selectedTab){
            ChatsView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
                .tag("Chat")
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag("Map")
            InventoryView()
                .tabItem {
                    Image(systemName: selectedTab == "Inventory" ? "door.garage.open" : "door.garage.closed")
                    Text("Inventory")
                }
                .tag("Inventory")
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Setting")
                }
                .tag("Setting")
        }
        .onAppear(){
            UITabBar.appearance().backgroundColor = UIColor(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xD8 / 255, alpha: 1.0)
            UITabBar.appearance().unselectedItemTintColor = UIColor(red: 204 / 255, green: 204 / 255, blue: 204 / 255, alpha: 1.0)
        }
        .tint(Color(red: 0xEC / 255, green: 0x95 / 255, blue: 0x83 / 255))
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}