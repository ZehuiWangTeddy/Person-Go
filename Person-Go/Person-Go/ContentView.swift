import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            ChatsView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            InventoryView()
                .tabItem {
                    Image(systemName: "door.garage.closed")
                    Text("Inventory")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Setting")
                }
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

#Preview {
    ContentView()
}
