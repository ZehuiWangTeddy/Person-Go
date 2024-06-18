import SwiftUI
import Supabase

struct RegistrationView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Sign Up")
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
                        await register()
                    }
                }, label: {
                    Text("Create Account")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Primary"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                })
            }
            .padding()
        }
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
    }

    private func register() async {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            showPopup(title: "Success", message: "Account created!")
            print(response)
        } catch {
            showPopup(title: "Error", message: "Failed to create account.")
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
    RegistrationView()
}
