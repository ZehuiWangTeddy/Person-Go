import SwiftUI
import Supabase

struct ChangePasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var isCurrentPasswordVisible: Bool = false
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
                PasswordField(title: "Current Password", text: $currentPassword, isPasswordVisible: $isCurrentPasswordVisible)
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
                        .cornerRadius(4)
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
            if isPasswordVisible {
                TextField(title, text: $text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(Color.gray)
            } else {
                SecureField(title, text: $text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(Color.gray)
            }
            
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

