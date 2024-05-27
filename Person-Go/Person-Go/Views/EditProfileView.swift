import SwiftUI
import Supabase

struct EditProfileView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        ZStack {
            Color("Background")
            VStack {
                Image("userprofile")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(100)
                    .padding(.vertical, 30)
    
                HStack {
                    Text("User Name")
                        .font(.title2)
                    Spacer()
                }
                TextField("new user name", text: $name)
                    .autocapitalization(.none)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Spacer().frame(height: 20)
                Button(action: {}, label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .cornerRadius(4)
                        .font(.title3)
                })
            }
            .padding()
        }
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
    }
}

#Preview {
    EditProfileView()
}
