import SwiftUI

struct AccountView: View {
    var body: some View {
        ScrollView { // Use ScrollView to make content start from the top
            VStack(alignment: .leading, spacing: 20) {
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
                .padding(.bottom, 10)

                NavigationLink(destination: ChangePasswordView()) {
                    Text("Password")
                        .font(.title2)
                        .padding()
                        .background(Color("Background"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(8)
                }
                Divider()
                .padding(.bottom, 10)
            }
            .padding()
            .background(Color("Background"))
        }
        .background(Color("Background"))
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)  // Reduces top empty space
    }
}

#Preview {
    AccountView()
}
