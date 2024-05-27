import SwiftUI
import Supabase

struct CircleWithTextView: View {
    var content: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .frame(width: 25, height: 25)
            
            Text(content)
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct ChatsView: View {
    @EnvironmentObject var userAuth: UserAuth

    var chatManager = ChatManager()
    @State private var friends: [Friend] = []
    
    @State var loading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text("Chats")
                            .font(.largeTitle)
                            .bold()
                        NavigationLink(destination: AddFriendsView()) {
                            Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView().environmentObject(userAuth)){
                            Image("userprofile")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(30)
                        }
                        Divider()
                            .frame(height: 2)
                    }
                    .padding(.horizontal)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                                        
                    if (friends.isEmpty) {
                        if (loading) {
                            Text("loadings...").padding()
                        } else {
                            Text("No Friends...").padding()
                        }
                        
                        Spacer()
                            .padding()
                    } else {
                        
                        List {
                            ForEach(friends, id: \.id) { friend in
                                NavigationLink(
                                    destination: ChatWindowView(friend: friend).environmentObject(userAuth)
                                ){
                                    HStack{
                                        AsyncImage(url: chatManager.retrieveAvatarPublicUrl(path: friend.profiles.avatarUrl ?? "")){ image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .cornerRadius(30)
                                                .frame(width: 50, height: 50)
                                        } placeholder: {
                                            Image("userprofile")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(30)
                                        }
                                        
                                        Text(friend.profiles.username ?? friend.profiles.id.uuidString)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        CircleWithTextView(content: "\(friend.totalInventory)")
                                        
                                    }
                                    .padding(.vertical, 8)
//                                    .background(Color("Background"))
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color("Background"))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal)
                        .padding(.vertical)
                        .refreshable {
                            loading = true
                            self.friends = await chatManager.fetchFriends(currentUser: userAuth.user!)
                            loading = false
                        }
                    }
                }
                .foregroundColor(Color("Text"))
                .padding(.vertical, 15)
            }
        }
        .onAppear {
            Task {
                self.friends = await chatManager.fetchFriends(currentUser: userAuth.user!)
            }
        }
    }
}

