import Foundation
import Supabase
import Combine

class UserAuth: ObservableObject {
    @Published var isLoggedin = false
    @Published var user: Supabase.User?
    @Published var profile: Profile?
    
    private var userManager = UserManager()

    func updateCurrentUser(user: Supabase.User)  {
        self.user = user
        
        Task {
            guard self.user != nil else {return}
            
            let profile = await userManager.getUserProfile(user: self.user!.id)
            DispatchQueue.main.async {
                self.profile = profile
            }
        }
    }
    
    func username() -> String
    {
        guard user != nil else { return "" }
        guard profile != nil else {
            return user!.email!
        }
        
        return profile!.username ?? user!.email!
    }
}
