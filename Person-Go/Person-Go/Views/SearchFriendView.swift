import SwiftUI
import Supabase

struct SearchFriendsView: View {
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    @State private var email: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var sizeClass

    var body: some View {
        GeometryReader { geometry in
            VStack() {
                HStack {
                    Text("Search Your Friend")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                Spacer().frame(height: 40)
                HStack {
                    Text("Email")
                        .font(.title2)
                    Spacer()
                }
                TextField("Enter friend's email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer().frame(height: 40)
                Button(action: {
                    Task {
                        await sendInvite()
                    }
                }, label: {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .foregroundColor(Color("Text"))
                        .cornerRadius(4)
                        .font(.title3)
                })
                Spacer().frame(height: 120)
                NavigationLink(destination: InviteFriendsView()){
                    Text("Invite")
                        .font(.title2)
                        .underline(true, color: Color("Primary"))
                        .padding(.vertical, 50)
                }
            }
            .padding()
        }
        .background(Color("Background"))
    }

    private func sendInvite() async {
        do {
            let response: AnyJSON = try await supabase.functions
                .invoke(
                    "send-invite",
                    options: FunctionInvokeOptions(
                        body: ["email": $email.wrappedValue]
                    )
                )
            print("response: \(response)")
        } catch {
            print("error: \(error)")
        }
    }
}

#Preview {
    SearchFriendsView()
}
