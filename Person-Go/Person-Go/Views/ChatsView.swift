import SwiftUI
import NukeUI
import Supabase

struct FriendAvatarView: View {
    let chatManager = ChatManager()
    var avatarUrl: String
    
    var body: some View {
        LazyImage(url: chatManager.retrieveAvatarPublicUrl(path: avatarUrl)) { state in
            if let image = state.image {
                image.resizable().frame(width: 50, height: 50).cornerRadius(30)
            } else if state.error != nil {
                AsyncImage(url: chatManager.getDefaultAvatar()){ image in
                    image.resizable().frame(width: 50, height: 50).cornerRadius(30)
                } placeholder: {
                    ProgressView()
                        .controlSize(.large)
                        .frame(width: 30, height: 30)
                }
            } else {
                ProgressView()
                    .controlSize(.large)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

struct CircleWithTextView: View {
    var content: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .frame(width: 30, height: 30)
            
            Text(content)
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct UnreadView: View {
    var body: some View {
        Circle()
            .fill(.red)
            .frame(width: 10, height: 10)
    }
}

struct ChatsView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    var chatManager = ChatManager()
    @State private var friends: [Friend] = []
    @State var loading = false
    
    @State var channel: Supabase.RealtimeChannelV2?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Chats")
                        .font(.largeTitle)
                        .bold()
                    NavigationLink(destination: AddFriendView().environmentObject(userAuth)) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    Spacer()
                }
                .overlay(
                    NavigationLink(destination: ProfileView().environmentObject(userAuth)) {
                        userAuth.getUserAvatar(width: 50, height: 50, radius: 30)
                    }
                        .padding(.trailing),
                    alignment: .trailing
                )
                Divider()
                if (friends.isEmpty) {
                    if (loading) {
                        Text("loadings...")
                    } else {
                        Text("No Friends...")
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(friends, id: \.id) { friend in
                            NavigationLink(
                                destination: ChatWindowView(friend: friend).environmentObject(userAuth)
                            ){
                                HStack{
                                    FriendAvatarView(avatarUrl: friend.profiles.avatarUrl ?? "")
                                        .padding()
                                    Text(friend.profiles.username ?? friend.profiles.id.uuidString)
                                        .font(.headline)
                                    Spacer()
                                    CircleWithTextView(content: "\(friend.totalInventory)")
                                    if (friend.totalUnread > 0) {
                                        UnreadView()
                                    }
                                }
                                
                            }
                            .listRowBackground(Color("Background"))
                            .listRowInsets(EdgeInsets())
                            //.padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .refreshable {
                        loading = true
                        self.friends = await chatManager.fetchFriends(currentUser: userAuth.user!)
                        loading = false
                    }
                }
            }
            .padding()
            .background(Color("Background"))
            .foregroundColor(Color("Text"))
            .onAppear {
                Task {
                    self.friends = await chatManager.fetchFriends(currentUser: userAuth.user!)
                    
                    let channel = await chatManager.getClient().channel(userAuth.user!.id.uuidString)
                    
                    let insertions = await channel.postgresChange(
                        InsertAction.self,
                        schema: "public",
                        table: "chats"
                    )
                    
                    await channel.subscribe()
                    
                    Task {
                        for await insert in insertions {
                            print("Inserted: \(insert.record)")
                            guard let receiverId = insert.record["receiver_id"]?.stringValue else { return }
                            
                            if (receiverId == userAuth.user!.id.uuidString.lowercased())  {
                                self.friends = await chatManager.fetchFriends(currentUser: userAuth.user!)
                            }
                        }
                    }
                    
                    self.channel = channel
                }
            }
            .onDisappear {
                Task {
                    self.friends = await chatManager.fetchFriends(currentUser: userAuth.user!)
                    if self.channel != nil {
                        await self.channel!.unsubscribe()
                        self.channel = nil
                    }
                }
            }
        }
    }
}
