import SwiftUI
import NukeUI

struct FriendProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    var chatManager = ChatManager()
    @State var friend: Friend
    @State private var info: FriendInfo? = nil
    
    var body: some View {
        VStack {
            if friend.profiles.avatarUrl != nil {
                LazyImage(url: chatManager.retrieveAvatarPublicUrl(path: friend.profiles.avatarUrl!)) { state in
                    if let image = state.image {
                        image.resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(100)
                            .padding(.top, 100)
                    } else if state.error != nil {
                        AsyncImage(url: chatManager.getDefaultAvatar()){ image in
                            image.resizable().frame(width: 50, height: 50).cornerRadius(30)
                        } placeholder: {
                            ProgressView()
                                .controlSize(.large)
                                .frame(width: 200, height: 200)
                        }
                    } else {
                        ProgressView()
                            .controlSize(.large)
                            .frame(width: 200, height: 200)
                    }
                }
            } else {
                LazyImage(url: chatManager.getDefaultAvatar()) { state in
                    if let image = state.image {
                        image.resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(100)
                            .padding(.top, 100)
                    } else if state.error != nil {
                        AsyncImage(url: chatManager.getDefaultAvatar()){ image in
                            image.resizable().frame(width: 50, height: 50).cornerRadius(30)
                        } placeholder: {
                            ProgressView()
                                .controlSize(.large)
                                .frame(width: 200, height: 200)
                        }
                    } else {
                        ProgressView()
                            .controlSize(.large)
                            .frame(width: 200, height: 200)
                    }
                }
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
        .background(Color("Background")) // Use the dynamic color
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
