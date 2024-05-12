import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Sign In")
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
                HStack {
                    Text("Password")
                        .font(.title2)
                    Spacer()
                }
                SecureField("", text: $password)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Spacer().frame(height: 20)
                Button(action: {
                    Task {
                        await signIn()
                    }
                }, label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .font(.title3)
                })
                VStack {
                    NavigationLink(destination: PasswordResetView()) {
                        Text("Forgot Password?")
                            .font(.title3)
                    }
                    Spacer().frame(height: 10)
                    NavigationLink(destination: RegistrationView()) {
                        Text("Sign Up")
                            .font(.title3)
                    }
                }
                .padding()
            }
        }
        .padding()
    }

    private func signIn() async {
//        do {
//            let response = try await client.auth.signIn(
//                email: email,
//                password: password
//            )
//            let user = response.user
            userAuth.isLoggedin = true
//        } catch {
//            print("Failed to sign in with error: \(error)")
//        }
    }
}

#Preview {
    LoginView()
}