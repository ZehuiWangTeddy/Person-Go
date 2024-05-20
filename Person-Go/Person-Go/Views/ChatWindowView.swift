import SwiftUI
import Supabase
import Combine

class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}

struct ChatBubbleView: View {
    var message: ChatMessage
    var friend: Friend
    var chatManager = ChatManager()
    
    var body: some View {
            HStack {
                if !message.isUserMessage(uid: friend.friendId) {
                    Spacer()
                    HStack(alignment: .top) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(message.message.message)
                                .padding(15)
                                .foregroundColor(.white)
                                .background(Color(red: 0xEC / 255, green: 0x95 / 255, blue: 0x83 / 255))
                                .cornerRadius(10)
                        }
                        Image("userprofile")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 8)
                    }
                } else {
                    AsyncImage(url: chatManager.retrieveAvatarPublicUrl(path: friend.profiles.avatarUrl ?? "")){ image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 8)
                    } placeholder: {
                        Image("userprofile")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.message.message)
                            .padding(15)
                            .foregroundColor(.white)
                            .background(Color(red: 128 / 255, green: 228 / 255, blue: 132 / 255))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 8)
    }
}

struct ChatWindowView: View {
    // Define a state variable to control the focus state of the text box
    @FocusState private var isFocused: Bool
    @State var channel: Supabase.RealtimeChannelV2?
    
    @EnvironmentObject var userAuth: UserAuth
    var chatManager = ChatManager()
    @State var loading: Bool = false
    
    var friend: Friend
    
    @StateObject var textObserver = TextFieldObserver()
    
    @State var messages: [ChatMessage] = []

    func sendMessage() {
        guard !loading else { return }
        
        loading = true
        
        defer {loading = false}
        
        let temp = textObserver.debouncedText
        guard temp.count > 0 else {
            print("no input")
            return
        }
        
        textObserver.searchText = ""
        isFocused = false // Unfocus

        if (temp.count > 0) {
            Task {
                // sleep
                let message = try await chatManager.sendMessage(sentId: userAuth.user!.id, receiverId: friend.friendId, content: temp)
                await chatManager.broadcastNewMessageEvent(channel: self.channel!, newMessage: message)
                await loadMessage()
                try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            }
        }
    }
    
    func loadMessage() async {
        self.messages = await chatManager.fetchMessages(currentUser: userAuth.user!, friendId: friend.friendId)
    }
    
    func joinRoom() {
        let channelName = chatManager.getRoomChannel(u1: userAuth.user!.id, u2: friend.friendId)
        let client = chatManager.getClient()
        
        Task {
            self.channel = await client.channel(channelName)
            guard channel != nil else {return}
        
            await channel!.subscribe()
            print("join channel \(channelName)")
            try await channel!.broadcast(
                event: "online",
                message: [
                    "user": userAuth.user!.id
                ]
            )
            
            let broadcastStream = await channel!.broadcastStream(event: "new-message")
            for await _ in broadcastStream {
                Task {
                    await loadMessage()
                }
                
            }
        }
    }
    
    var body: some View {
        Color("Background")
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: FriendProfileView()) {
                            Text(friend.profiles.username ?? friend.profiles.id.uuidString)
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal, 25)
                        }
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                            .padding(.vertical, 5)
                        
                        ScrollViewReader { value in
                            ScrollView {
                                VStack(alignment: .leading) {
                                    ForEach(messages, id: \.id) { message in
                                        ChatBubbleView(message: message, friend: friend)
                                            .id(message.id)
                                    }.onChange(of: messages.count) { _ in
                                        value.scrollTo(messages.last?.id)
                                    }
                                }
                            }
                            .onAppear {
                                withAnimation {
                                    value.scrollTo(messages.last?.id)
                                }
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        TextField("type...",
                            text: $textObserver.searchText
//                            ,onCommit: sendMessage
                        )
                        .disabled(loading)
                        .onSubmit {
                            print("onsubmit..")
                            sendMessage()
                        }
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .padding([.leading, .top, .bottom])
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle")
                                .controlSize(.large)
                                .fixedSize()
                                .frame(height: 60)
                        }
                        .disabled(loading)
                        .controlSize(.large)
                        .padding()
                    }
                }
                .onAppear {
                    Task {
                        await loadMessage()
                    }
                    joinRoom()
                }
                .onDisappear {
                    chatManager.clearChannel()
                    // unset channel
                    self.channel = nil
                }
            )
        .toolbar(.hidden, for: .tabBar)
        .foregroundColor(Color("Text"))
    }
}


//#Preview {
//    ChatWindowView(friend: Friend(id: 1, friendId: UUID(), totalInventory: 10, profiles: Profile(id: UUID(), username: "preview")))
//}
