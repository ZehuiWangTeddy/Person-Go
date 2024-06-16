import SwiftUI
import Supabase

struct SearchFriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    let client = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
    @EnvironmentObject var userAuth: UserAuth
    
    let userManager = UserManager()
    
    @State private var email: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var sizeClass
    
    // Sheet
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Info"
    
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
                        let rs = await addFriend()
                        if (rs) {
                            presentationMode.wrappedValue.dismiss()
                        }
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
                NavigationLink(destination: InviteFriendView()){
                    Text("Invite")
                        .font(.title2)
                        .underline(true, color: Color("Primary"))
                        .padding(.vertical, 50)
                }
            }
            .padding()
        }
        .background(Color("Background"))
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("dismiss"))
            )
        }
    }
    
    private func addFriend() async -> Bool {
        let friend = await userManager.findUserByEmail(email: self.email)
        guard friend != nil else {
            alertTitle = "error"
            alertMessage = "User not found!!"
            showAlert.toggle()
            
            return false
        }
        
        let exists = await userManager.isFriendAlready(user: userAuth.user!.id, friend: friend!)
        if (exists) {
            alertTitle = "error"
            alertMessage = "You're already friends."
            showAlert.toggle()
            
            return false
        }
        
        let rs = await userManager.addFriendShip(user: userAuth.user!.id, friend: friend!)
        
        if (!rs) {
            alertTitle = "error"
            alertMessage = "User not found!!"
            showAlert.toggle()
            
            return false
        }
        
        alertTitle = "success"
        alertMessage = "Friend added!!"
        showAlert.toggle()
        
        return true
    }
}

#Preview {
    SearchFriendsView()
}

