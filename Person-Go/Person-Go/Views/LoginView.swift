import SwiftUI
import Supabase

struct LoginView: View {
    
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = "test@test.com"
    @State private var password: String = "1234"

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
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
//                        Task {
//                            await signIn()
//                        }
                        signInButtonTapped()
                    }, label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Primary"))
                            .foregroundColor(Color("Text"))
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
            .background(Color("Background"))
        }
        .foregroundColor(Color("Text"))
    }
    
    func signInButtonTapped() {
        Task {
//            defer { userAuth.isLoggedin = false }
              do {
                let response = try await client.auth.signIn (
                    email: email,
                    password: password
                )
                
                userAuth.isLoggedin = true
                userAuth.updateCurrentUser(user: response.user)
              } catch {
                print("error: \(error)")
              }
            
        }
      }

    private func signIn() async {
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            let user = response.user
            print(user)
            userAuth.isLoggedin = true
        } catch {
            print("Failed to sign in with error: \(error)")
        }
    }
}

#Preview {
    LoginView()
}
