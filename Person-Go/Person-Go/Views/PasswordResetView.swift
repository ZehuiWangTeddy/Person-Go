import SwiftUI
import Supabase

struct PasswordResetView: View {
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
                    Text("Forgot Password?")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                Divider()
                    .frame(height: 2)
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(Color("Text"))
                    .cornerRadius(8)
                    .foregroundColor(Color.gray)
                    .autocapitalization(.none)
                    .frame(height: 50)
                Button(action: {
                    Task {
                        await resetPassword()
                    }
                }, label: {
                    Text("Send Email")
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
    
    private func resetPassword() async {
        do {
            try await supabase.auth.resetPasswordForEmail(
                email
            )
            showPopup(title: "Success", message: "Password reset email sent!")
        } catch {
            showPopup(title: "Error", message: "Failed to send password reset email.")
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
    PasswordResetView()
}
