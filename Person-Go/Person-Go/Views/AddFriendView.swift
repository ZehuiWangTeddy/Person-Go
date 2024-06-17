import SwiftUI
import Supabase

enum AddFriendError: Error {
    case userNotFound
    case alreadyFriends
    case unknownError
    case emptyField
}

struct AddFriendView: View {
    @Environment(\.presentationMode) var presentationMode
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    @EnvironmentObject var userAuth: UserAuth

    let userManager = UserManager()

    @State private var email: String = ""
    @State private var showingAlert = false
    @State private var showingChoice = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

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
                        await addFriend()
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
            if showingChoice {
                Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Send Invite"), action: {
                    Task {
                        await sendInvite()
                        self.showingChoice = false
                    }
                }), secondaryButton: .cancel(Text("Cancel"), action: {
                    print("cancel")
                    self.showingChoice = false
                }))
            } else {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
        }
    }

    private func addFriend() async {
        do {
            guard !email.isEmpty else {
                throw AddFriendError.emptyField
            }

            guard let friend = try await userManager.findUserByEmail(email: self.email) else {
                throw AddFriendError.userNotFound
            }

            if try await userManager.isFriendAlready(user: userAuth.user!.id, friend: friend) {
                throw AddFriendError.alreadyFriends
            }

            let success = try await userManager.addFriendShip(user: userAuth.user!.id, friend: friend)
            if !success {
                throw AddFriendError.unknownError
            }

            showPopup(title: "Success", message: "Friend added!")
        } catch let error as AddFriendError {
            handleAddFriendError(error) 
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
            showPopup(title: "Error", message: "An unexpected error occurred.")
        }
    }

    private func handleAddFriendError(_ error: AddFriendError) {
        switch error {
        case .emptyField:
            showPopup(title: "Empty Field", message: "Please enter an email address")
        case .userNotFound:
            showChoice(title: "User not found", message: "No user with this email exists. Do you want to invite them?")
        case .alreadyFriends:
            showPopup(title: "Error", message: "You're already friends.")
        case .unknownError:
            showPopup(title: "Error", message: "An error occurred while adding the friend.")
        }
    }

    private func sendInvite() async {
        do {
            let response: AnyJSON = try await supabase
                .functions
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
    }

    private func showPopup(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showingAlert = true
        }
    }

    private func showChoice(title: String, message: String) {
        self.showingChoice = true
        showPopup(title: title, message: message)
    }
}

#Preview {
    AddFriendView()
}
