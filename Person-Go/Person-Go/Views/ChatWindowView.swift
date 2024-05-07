import SwiftUI

struct ChatBubbleView: View {
    var message: ChatMessage

    var body: some View {
            HStack {
                if message.isMyMessage {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(message.content)
                            .padding(15)
                            .foregroundColor(.white)
                            .background(Color(red: 0xEC / 255, green: 0x95 / 255, blue: 0x83 / 255))
                            .cornerRadius(10)
                    }
                    Image(message.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 8)
                        .background(Color.clear)
                } else {
                    Image(message.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.content)
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
    @State var content: String = ""
    // Define a state variable to control the focus state of the text box
    @FocusState private var isFocused: Bool

    @State var messages: [ChatMessage] = [
        ChatMessage(content: "Hello!", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Hi there!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Go", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Come!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Hello!", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Hi there!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Go", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Come!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Hello!", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Hi there!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Go", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Come!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Hello!", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Hi there!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Go", isMyMessage: true, imageName: "userprofile"),
        ChatMessage(content: "Come!", isMyMessage: false, imageName: "userprofile"),
        ChatMessage(content: "Come!", isMyMessage: false, imageName: "userprofile")
    ]
    
    func sendMessage() {
        
        if (content.count > 0) {
            messages.append(ChatMessage(content: content, isMyMessage: true, imageName: "userprofile"))
        }
        
        content = "" // clear text
        isFocused = false // Unfocus
    }

    
    var body: some View {
        Color(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xD8 / 255)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: FriendProfileView()) {
                            Text("Joy")
                                    .font(.title)
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
                                        ChatBubbleView(message: message)
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
                              text: $content,
                              onEditingChanged: { isEditing in
                                print("onEditingChanged::\(content)")
                              },
                              onCommit: sendMessage
                        )
                        .onChange(of: isFocused) { isFocused in
                            print(isFocused)
                        }
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .padding([.leading, .top, .bottom])
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle")
                                .controlSize(.large)
                                .fixedSize()
                                .frame(height: 40)
                        }
                        .controlSize(.large)
                        .padding()
                    }
                }
        )
        .toolbar(.hidden, for: .tabBar)
    }
}


struct ChatWindowView_Previews: PreviewProvider {
    static var previews: some View {
        ChatWindowView(content: "")
    }
}
