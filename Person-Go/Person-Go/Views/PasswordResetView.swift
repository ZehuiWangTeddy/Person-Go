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
                Button(action: {
                    Task {
                        await resetPassword()
                    }
                }, label: {
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
