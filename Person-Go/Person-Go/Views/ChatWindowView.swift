import SwiftUI
import NukeUI
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
        // Create an ISO8601DateFormatter that is used to parse date strings in ISO 8601 format
        
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
    
    func loadAvatar(url: URL, hasPadding: Bool = false) -> some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image.resizable().frame(width: 30, height: 30).padding(.trailing, 8)
            } else if state.error != nil {
                AsyncImage(url: chatManager.getDefaultAvatar()){ image in
                    if hasPadding {
                        image
                        .resizable()
                        .frame(width: 30, height: 30)
                            .padding(.trailing, 10)
                    } else {
                        image
                        .resizable()
                        .frame(width: 30, height: 30)
                    }
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
//                        userAuth.getUserAvatar(width: 30, height: 30, radius: 0, padding: 8, edges: .trailing)
                        
//                        LazyImage(request: ImageRequest(
//                            url: chatManager.retrieveAvatarPublicUrl(path: userAuth.profile!.avatarUrl ?? ""),
//                            processors: [.resize(height: 10)]
//                        ))
//                        .padding(.trailing, 8)
                        
                        loadAvatar(url: chatManager.retrieveAvatarPublicUrl(path: userAuth.profile!.avatarUrl ?? ""), hasPadding: false)
                    }
                } else {
                    HStack(alignment: .top, spacing: 0) {
//                        AsyncImage(url: chatManager.retrieveAvatarPublicUrl(path: friend.profiles.avatarUrl ?? "")){ image in
//                            image
//                                .resizable()
////                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 30, height: 30)
//                                .padding(.trailing, 8)
//                        } placeholder: {
//                            ProgressView()
//                                .controlSize(.large)
//                                .frame(width: 30, height: 30)
//                        }
                        
                        loadAvatar(url: chatManager.retrieveAvatarPublicUrl(path: friend.profiles.avatarUrl ?? ""))

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
    @State private var keyboardHeight: CGFloat = 0
    
    var friend: Friend
    
    @StateObject var textObserver = TextFieldObserver()
    @State private var textInput: String = ""
    
    @State var messages: [ChatMessage] = []
    
    let columns: [GridItem] = [.init(.fixed(110)),.init(.fixed(110)),.init(.fixed(110))]

    func sendMessage() {
        guard !loading else { return }
        
        loading = true
        
        defer {loading = false}
        
//        let temp = textObserver.debouncedText
        let temp = textInput
        guard temp.count > 0 else {
            print("no input")
            return
        }
        
//        textObserver.searchText = ""

        DispatchQueue.main.async {
            textInput = ""
            isFocused = false // Unfocus
        }
        
        if (temp.count > 0) {
            Task {
                let message = try await chatManager.sendMessage(sentId: userAuth.user!.id, receiverId: friend.friendId, content: temp)
                self.messages.append(ChatMessage(message: message, type: .message))
                let channelName = chatManager.getRoomChannel(u1: userAuth.user!.id, u2: friend.friendId)
                await chatManager.broadcastNewMessageEvent(cname: channelName, newMessage: message)
//                await loadMessage()
            }
        }
    }
    
    func loadMessage() async {
        self.messages = await chatManager.fetchMessages(currentUser: userAuth.user!, friendId: friend.friendId)
    }
    
    func joinRoom() {
        Task {
            let channelName = chatManager.getRoomChannel(u1: userAuth.user!.id, u2: friend.friendId)
            let channel = await chatManager.getClient().channel(channelName)
            print(channelName)
//            await channel.subscribe()
            
//            print("channel status: ", await channel.status)
            
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
                    guard let sentId = insert.record["sent_id"]?.stringValue else { return }
                    
                    print(userAuth.user!.id.uuidString.lowercased())
                        if (receiverId == userAuth.user!.id.uuidString.lowercased() && sentId == friend.friendId.uuidString.lowercased()) || (sentId == userAuth.user!.id.uuidString.lowercased() && receiverId == friend.friendId.uuidString.lowercased())  {
                        await loadMessage()
                    }
                }
            }

            Task {
                let broadcastStream = await channel.broadcastStream(event: "new-message")
                for await _ in broadcastStream {
                    print("new-message...")
                    Task {
                        await loadMessage()
                    }
                }
            }
            
            self.channel = channel
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
                                LazyVStack(alignment: .leading) {
                                    withAnimation {
                                        ForEach(messages, id: \.id) { message in
                                            ChatBubbleView(message: message, friend: friend)
                                                .id(message.id)
                                                .environmentObject(userAuth)
                                        }.onChange(of: messages.count) { _ in
                                            value.scrollTo(messages.last?.id)
                                        }.onChange(of: isFocused) { _ in
                                            value.scrollTo(messages.last?.id)
                                        }
                                    }
                                }
//                                .offset(y: isFocused ? -300 : 0)
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
//                                  text: $textObserver.searchText
                                  text: $textInput
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
                    .padding(.bottom, keyboardHeight)
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
                if self.channel != nil {
                    Task {
                        await self.channel!.unsubscribe()
                    }
                }
            }

    }
}
