import SwiftUI

struct FriendProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    @Environment(\.colorScheme) var colorScheme
    
    var chatManager = ChatManager()
    @State var friend: Friend
    @State private var info: FriendInfo? = nil
    
    var body: some View {
        ScrollView { // Wrap the VStack in a ScrollView
            VStack {
                AsyncImage(url: chatManager.retrieveAvatarPublicUrl(path: friend.profiles.avatarUrl ?? "")){ image in
                    image.resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .padding(.top, 100)
                } placeholder: {
                    Image("userprofile")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .padding(.top, 100)
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("Username")
                                .font(.title2)
                                .padding(.bottom)
                            Spacer()
                            Text(friend.profiles.username!)
                                .font(.title2)
                                .padding(.bottom)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Email")
                                .font(.title2)
                                .padding(.bottom)
                            Spacer()
                            Text(info?.email ?? "")
                                .font(.title2)
                                .padding(.bottom)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Quickstrike")
                                .font(.title2)
                                .padding(.bottom)
                            Spacer()
                            Text("\(info?.small ?? 0)")
                                .font(.title2)
                                .padding(.bottom)
                        }
                        Divider()
                        
                        HStack {
                            Text("Blaze Rocket")
                                .font(.title2)
                                .padding(.bottom)
                            Spacer()
                            Text("\(info?.medium ?? 0)")
                                .font(.title2)
                                .padding(.bottom)
                        }
                        Divider()
                        
                        HStack {
                            Text("Phoenix Inferno")
                                .font(.title2)
                                .padding(.bottom)
                            Spacer()
                            Text("\(info?.large ?? 0)")
                                .font(.title2)
                                .padding(.bottom)
                        }
                        Divider()
                    }
                    .padding()
                }
                .padding(.top, 50) // More space between the profile picture and the text
                
                Spacer() // Pushes the content to the top
            }
        }
        .background(colorScheme == .light ? Color(hex: "#F3EBD8") : Color(hex: "#271F0C")) // Use the dynamic color
        .edgesIgnoringSafeArea(.all) // Make sure the background color fills the entire screen
        .onAppear {
            Task {
                let info = await chatManager.fetchFriendInfo(id: friend.friendId)
                
                guard info != nil else { return }
                
                
                DispatchQueue.main.async {
                    self.info = info
                }
            }
            
        }
    }
}

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
