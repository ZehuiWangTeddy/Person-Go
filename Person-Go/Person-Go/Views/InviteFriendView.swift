import SwiftUI
import Supabase

struct User: Codable {
    let id: UUID
    let email: String
}

struct InviteFriendView: View {
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    
    @State private var email: String = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var sizeClass
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                HStack {
                    Text("Add Your Friend")
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
            }
            .padding()
        }
        .background(Color("Background"))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
    }
    
    private func sendInvite() async {
        let email = $email.wrappedValue
        
        if let userData = await getUser(email: email) {
            if userData.isEmpty {
                do {
                    let response: AnyJSON = try await supabase.functions
                        .invoke(
                            "send-invite",
                            options: FunctionInvokeOptions(body: ["email": email])
                        )
                    print("Invite sent: \(response)")
                    showPopup(title: "Success", message: "An invite has been sent to the provided email address.")
                } catch {
                    print("Error sending invite: \(error)")
                    showPopup(title: "Error", message: "There was an error sending the invite. Please try again.")
                }
            } else {
                await addFriend(users: userData)
            }
        }
    }
    
    private func getUser(email: String) async -> [User]? {
        do {
            let users: [User] = try await supabase
                .from("users")
                .select("id, email")
                .eq("email", value: email)
                .execute()
                .value
            return users
        } catch {
            print("Error fetching user data: \(error)")
            showPopup(title: "Error", message: "There was an error fetching the user data. Please try again.")
            return nil
        }
    }
    
    private func addFriend(users: [User]) async {
        let currentUserId: UUID = supabase.auth.currentUser!.id;
        if let newFriendId = users.first?.id {
            do {
                try await supabase
                    .rpc("add_friend", params: ["user_id_param": currentUserId, "friend_id_param": newFriendId])
                    .execute()
                print("Successfully added friend")
                showPopup(title: "Success", message: "The user has been successfully added as a friend.")
            } catch {
                print("Error adding friend: \(error)")
                showPopup(title: "Error", message: "There was an error adding the user as a friend. Please try again.")
            }
        } else {
            print("No user data provided")
            showPopup(title: "Error", message: "No user data was provided to add as a friend.")
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

