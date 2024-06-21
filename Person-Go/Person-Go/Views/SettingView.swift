import SwiftUI
import Supabase

struct SettingView: View {
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    @EnvironmentObject var userAuth: UserAuth
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        NavigationLink(destination: AccountView()) {
                            Text("Account")
                        }
                        Divider()
                        NavigationLink(destination: SecurityView()) {
                            Text("Security")
                        }
                        Divider()
                        NavigationLink(destination: NotificationView()) {
                            Text("Notification")
                        }
                        Divider()
                        NavigationLink(destination: AboutView()) {
                            Text("About")
                        }
                        Divider()
                    }
                }
                Button(action: {
                    Task {
                        await signOut()
                    }
                }) {
                    Text("Log out")
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
            .foregroundColor(Color("Text"))
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
    }
    
    private func signOut() async {
        do {
            try await client.auth.signOut()
            userAuth.isLoggedin = false
        } catch {
            showPopup(title: "Error", message: "There was an error logging out!")
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
    SettingView()
}
