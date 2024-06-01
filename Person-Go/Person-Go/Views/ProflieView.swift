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
                            //                            .padding(.bottom)
                            Spacer()
                            Text(userAuth.username())
                                .font(.title2)
                            //                            .padding(.bottom)
                        }
                        .padding(.horizontal, 25)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                        //                        .padding(.vertical, 15)
                        HStack{
                            Text("Email")
                                .font(.title2)
                            //                            .padding(.bottom)
                            Spacer()
                            Text(email())
                                .font(.title2)
                            //                            .padding(.bottom)
                        }
                        .padding(.horizontal, 25)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                        //                        .padding(.vertical, 15)
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

