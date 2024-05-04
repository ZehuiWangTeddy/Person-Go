import SwiftUI

struct ProfileView: View {
    var body: some View {
        Color(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xD8 / 255)
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
                        .font(.headline)
                    Spacer()
                    Text("Joy")
                        .padding(.horizontal,50)
                }
                .padding(.horizontal, 25)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                    .padding(.vertical, 15)
                HStack{
                    Text("Email")
                        .font(.headline)
                    Spacer()
                    Text("qq@qq.com")
                        .padding(.horizontal,50)
                }
                .padding(.horizontal, 25)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                Text("EDIT")
                    .font(.headline)
                    .underline(true, color: Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                    .padding(.vertical, 50)
            }
        )
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
