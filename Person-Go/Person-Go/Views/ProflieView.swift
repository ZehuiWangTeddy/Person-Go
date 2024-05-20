import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var userAuth: UserAuth
    
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
                    Image("userprofile")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .padding(.vertical, 30)
                    HStack{
                        Text("User Name")
                            .font(.title2)
                        Spacer()
                        Text(userAuth.username())
                            .padding(.horizontal,50)
                    }
                    .padding(.horizontal, 25)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                        .padding(.vertical, 15)
                    HStack{
                        Text("Email")
                            .font(.title2)
                        Spacer()
                        Text(email())
                            .padding(.horizontal,50)
                    }
                    .padding(.horizontal, 25)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                    Text("EDIT")
                        .font(.title2)
                        .underline(true, color: Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                        .padding(.vertical, 50)
                }
            )
        }
            .background(Color("Background"))
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
