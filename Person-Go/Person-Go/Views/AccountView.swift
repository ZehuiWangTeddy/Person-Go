import SwiftUI

struct AccountView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Account Settings")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    NavigationLink(destination: ChangeEmailView()) {
                        Text("Email")
                    }
                    Divider()
                    NavigationLink(destination: ChangePasswordView()) {
                        Text("Password")
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
    }
}

#Preview {
    AccountView()
}
