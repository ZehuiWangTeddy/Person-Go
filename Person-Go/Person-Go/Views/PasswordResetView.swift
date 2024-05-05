import SwiftUI
import Supabase

struct PasswordResetView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    var body: some View {
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
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .font(.title3)
            })
        }
        .padding()
    }
}

#Preview {
    PasswordResetView()
}
