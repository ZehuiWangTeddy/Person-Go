import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    let chatManager = ChatManager()
    
    func email() -> String
    {
        guard userAuth.user != nil else { return "" }
        
        return userAuth.user!.email ?? ""
    }
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack{
                        userAuth.getUserAvatar()
                        
                        HStack{
                            Text("User Name")
                                .font(.title2)
                            Spacer()
                            Text(userAuth.username())
                                .font(.title2)
                        }
                        .padding(.horizontal, 25)
                        Divider()
                        HStack{
                            Text("Email")
                                .font(.title2)
                            Spacer()
                            Text(email())
                                .font(.title2)
                        }
                        .padding(.horizontal, 25)
                        Divider()
                        NavigationLink(destination: EditProfileView().environmentObject(userAuth)){
                            Text("EDIT")
                                .font(.title2)
                                .underline(true, color: Color("Primary"))
                                .padding(.vertical, 50)
                        }
                    }
                )
        }
        .background(Color("Background"))
        .onAppear {
            Task {
                await userAuth.getLatestProfile(id: userAuth.user!.id)
            }
        }
    }
}
