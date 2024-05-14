import SwiftUI
import Supabase

struct PasswordResetView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    var body: some View {
        ZStack {
            Color("Background")
            VStack {
                HStack {
                    Text("Forgot Password")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                Spacer().frame(height: 20)
                HStack {
                    Text("Email")
                        .font(.title2)
                    Spacer()
                }
                TextField("", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Spacer().frame(height: 20)
                Button(action: {}, label: {
                    Text("Send Email")
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
    PasswordResetView()
}
