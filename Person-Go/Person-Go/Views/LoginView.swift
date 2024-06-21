import SwiftUI
import Supabase

struct LoginView: View {
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)

    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                VStack(spacing: 20) {
                    HStack {
                        Text("Sign In")
                                .font(.largeTitle)
                                .bold()
                        Spacer()
                    }
                    Divider()
                        .frame(height: 2)
                    Group {
                        TextField("Email", text: $email)
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(Color("Text"))
                    .cornerRadius(8)
                    .foregroundColor(Color.gray)
                    .autocapitalization(.none)
                    .frame(height: 50)
                    Button(action: {
                        Task {
                            await signIn()
                        }
                    }, label: {
                        Text("Sign In")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Primary"))
                            .foregroundColor(Color("Text"))
                            .cornerRadius(8)
                    })
                    VStack(spacing: 10) {
                        NavigationLink(destination: PasswordResetView()) {
                            Text("Forgot Password?")
                                    .font(.title3)
                        }
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
