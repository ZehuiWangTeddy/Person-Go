import SwiftUI
import Supabase

struct RegistrationView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var email: String = ""
    @State private var password: String = ""

    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    var body: some View {
        ZStack {
            Color("Background")
            VStack {
                HStack {
                    Text("Sign Up")
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
                HStack {
                    Text("Password")
                        .font(.title2)
                    Spacer()
                }
                SecureField("", text: $password)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Spacer().frame(height: 20)
                Button(action: {
                    Task {
                        await register()
                    }

                }, label: {
                    Text("Create Account")
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
    }

    private func register() async {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            print(response)
        } catch {
            print("error: \(error)")
        }
    }
}

#Preview {
    RegistrationView()
}
