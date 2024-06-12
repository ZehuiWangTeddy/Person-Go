import SwiftUI
import Supabase

struct ChangePasswordView: View {
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmNewPasswordVisible: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Password")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("Text"))
                Divider()
                    .frame(height: 2)
                PasswordField(title: "New Password", text: $newPassword, isPasswordVisible: $isNewPasswordVisible)
                PasswordField(title: "Confirm New Password", text: $confirmNewPassword, isPasswordVisible: $isConfirmNewPasswordVisible)
                Button(action: {
                    Task {
                        await updatePassword()
                    }
                }) {
                    Text("Reset Password")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Primary"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color("Background"))
        }
        .background(Color("Background"))
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updatePassword() async {
        do {
            if newPassword != confirmNewPassword {
                throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "The passwords do not match."])
            }
            
            let response: AnyJSON = try await supabase.functions
                .invoke(
                    "update-password",
                    options: FunctionInvokeOptions(
                        body: ["password": $newPassword.wrappedValue]
                    )
                )
            print("response: \(response)")
        } catch {
            print("error: \(error)")
        }
    }
}

struct PasswordField: View {
    var title: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isPasswordVisible {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .autocapitalization(.none)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .frame(height: 50)
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing, 15)
            }
        }
    }
}

#Preview {
    ChangePasswordView()
}
