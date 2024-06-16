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
    @EnvironmentObject var userAuth: UserAuth
    
    var message: ChatMessage
    var friend: Friend
    var chatManager = ChatManager()
    
    func formattime(dateString: String) -> String {
        // 创建一个 ISO8601DateFormatter 用于解析 ISO 8601 格式的日期字符串
        
        let date = chatManager.parseDate(dateString: dateString)
        guard date != nil else {
            return ""
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date!) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedTime = timeFormatter.string(from: date!)
            return formattedTime
        } else {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM-dd HH:mm"
            let formattedDate = displayFormatter.string(from: date!)
            return formattedDate
        }
    }
    
    var body: some View {
        
        if (message.type == .message) {
            HStack(alignment: .top) {
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
                        userAuth.getUserAvatar(width: 30, height: 30, radius: 0, padding: 8, edges: .trailing)
                    }
                } else {
                    HStack(alignment: .top, spacing: 0) {
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
                        
                        VStack(alignment: .leading) {
                            Text(message.message.message)
                                .padding(15)
                                .foregroundColor(.white)
                                .background(Color(red: 128 / 255, green: 228 / 255, blue: 132 / 255))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        } else {
            HStack(alignment: .center) {
                Spacer()
                Text(self.formattime(dateString: message.message.sentAt))
//                    .foregroundColor(.white)
//                    .background(Color(red: 128 / 255, green: 128 / 255, blue: 128 / 255))
                    .padding()
                Spacer()
            }
        }
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
                print("send messages...")
                // sleep
                do {
                    let message = try await chatManager.sendMessage(sentId: userAuth.user!.id, receiverId: friend.friendId, content: temp)
                    chatManager.broadcastNewMessageEvent(channel: self.channel!, newMessage: message)
                    await loadMessage()
                    try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                } catch {
                    print("\(error)")
                }
            }
        }
    }
    
    func loadMessage() async {
        self.messages = await chatManager.fetchMessages(currentUser: userAuth.user!, friendId: friend.friendId)
        
        let pure_messages = self.messages.filter({ $0.type == .message })
        
        // calc last time is over 1hour
        if pure_messages.count > 1 {
            let last = pure_messages.last!.message
            let lasttime = chatManager.parseDate(dateString: last.sentAt)
            
            if lasttime != nil {
                let now = Date()
                var diff = now.timeIntervalSince(lasttime!)
                diff = abs(diff)
                
                if diff > 3600 {
                    self.messages.insert(ChatMessage(message: Message(messageId: 0, message: " ", sentId: UUID(), receiverId: UUID(), sentAt: now.ISO8601Format()), type: .system), at: self.messages.count - 1)
                }
            }
        }
    }
    
    func joinRoom() {
        let channelName = chatManager.getRoomChannel(u1: userAuth.user!.id, u2: friend.friendId)
        let client = chatManager.getClient()
        
        Task {
            self.channel = await client.channel(channelName)
            guard channel != nil else {
                return
            }
            
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
                        NavigationLink(destination: FriendProfileView(friend: friend).environmentObject(userAuth)) {
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
                                            .environmentObject(userAuth)
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
                
            )
            .toolbar(.hidden, for: .tabBar)
            .foregroundColor(Color("Text"))
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
    }
}
