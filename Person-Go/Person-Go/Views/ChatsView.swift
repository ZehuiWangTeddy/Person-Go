import SwiftUI

struct ChatsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xD8 / 255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Text("Chats")
                            .font(.title)
                        NavigationLink(destination: AddFriendsView()) {
                            Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()){
                            Image("userprofile")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(30)
                        }
                    }
                    .padding(25)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    List {
                        NavigationLink(destination: ChatWindowView()){
                            HStack{
                                Image("userprofile")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(30)
                                Text("Zoe")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "01.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .padding(.vertical, 8)
                        }
                        NavigationLink(destination: ChatWindowView()){
                            HStack{
                                Image("userprofile")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(30)
                                Text("Moe")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "02.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .padding(.vertical, 8)
                        }
                        NavigationLink(destination: ChatWindowView()){
                            HStack{
                                Image("userprofile")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(30)
                                Text("Yoe")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "03.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .padding(.vertical, 8)
                        }
                        NavigationLink(destination: ChatWindowView()){
                            HStack{
                                Image("userprofile")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(30)
                                Text("Qoe")
                                    .font(.headline)
                            }
                            .padding(.vertical, 8)
                        }
                        NavigationLink(destination: ChatWindowView()){
                            HStack{
                                Image("userprofile")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(30)
                                Text("Poe")
                                    .font(.headline)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xD8 / 255))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal)
                    .padding(.vertical)
                }
                .padding(.vertical, 15)
            }
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
