import SwiftUI

struct FriendProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    
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
        .background(Color("Background"))
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
