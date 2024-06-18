import SwiftUI
import Supabase

struct LoginView: View {
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = "test@test.com"
    @State private var password: String = "1234"

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

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
                        Task {
                            await signIn()
                        }
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
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
    }

    private func signIn() async {
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            userAuth.isLoggedin = true
            userAuth.updateCurrentUser(user: response.user)
        } catch {
            showPopup(title: "Error", message: "Invalid credentials.")
            print("error: \(error)")
        }
    }
    
    private func showPopup(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showingAlert = true
        }
    }
}

#Preview {
    LoginView()
}
