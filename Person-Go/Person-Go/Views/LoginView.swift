import SwiftUI
import Supabase

let apiUrl: String = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String

struct LoginView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .border(Color.gray, width: 0.5)
            SecureField("Password", text: $password)
                .padding()
                .border(Color.gray, width: 0.5)
            Button(action: {
                Task {
                    await signIn()
                }
            }) {
                Text("Log In")
            }
        }
        .padding()
    }

    private func signIn() async {
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            let user = response.user
            print("User \(user.email) signed in successfully!")
            userAuth.isLoggedin = true
        } catch {
            print("Failed to sign in with error: \(error)")
        }
    }
}
