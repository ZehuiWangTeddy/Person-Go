import SwiftUI

struct AccountView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Account Settings")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("Text"))
                Divider()
                    .frame(height: 2)
                NavigationLink(destination: ChangeEmailView()) {
                    Text("Email")
                        .font(.title2)
                        .padding()
                        .background(Color("Background"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                }
                Divider()
                    .frame(height: 2)
                NavigationLink(destination: ChangePasswordView()) {
                    Text("Password")
                        .font(.title2)
                        .padding()
                        .background(Color("Background"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                }
                Divider()
            }
            .padding()
            .background(Color("Background"))
        }
        .background(Color("Background"))
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AccountView()
}
