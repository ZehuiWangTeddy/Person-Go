import SwiftUI
import Supabase

struct ChangeEmailView: View {
    @State private var email: String = ""
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Email")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("Text"))
                Divider()
                    .frame(height: 2)
                TextField("New Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(Color.gray)
                    .autocapitalization(.none)
                Button(action: {
                    Task {
                        await updateEmail()
                    }
                }) {
                    Text("Update Email")
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
        .navigationTitle("Change Email")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
    }
    
    private func updateEmail() async {
        do {
            let response: AnyJSON = try await supabase.functions
                .invoke(
                    "update-email",
                    options: FunctionInvokeOptions(
                        body: ["email": $email.wrappedValue]
                    )
                )
            showPopup(title: "Success", message: "Email updated!")
            print("response: \(response)")
        } catch {
            showPopup(title: "Error", message: "Failed to update email.")
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
    ChangeEmailView()
}
