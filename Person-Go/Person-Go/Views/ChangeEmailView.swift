import SwiftUI

struct ChangeEmailView: View {
    @State private var email: String = ""
    
    var body: some View {
        ScrollView { // Use ScrollView to make content start from the top
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

                Button(action: {
                    // Handle email update
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
        .navigationBarTitleDisplayMode(.inline)  // Reduces top empty space
    }
}

#Preview {
    ChangeEmailView()
}
