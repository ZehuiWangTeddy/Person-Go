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
            
            let profile = await getLatestProfile(id: self.user!.id)
            DispatchQueue.main.async {
                self.profile = profile
            }
        }
    }
    
    func getLatestProfile(id: UUID) async -> Profile {
        let profile = await userManager.getUserProfile(user: id)
        return profile!
    }
    
    func updateUserProfile(username: String) {
        Task {
            guard self.user != nil else {return}
            
            _ = await userManager.updateUserProfile(user: self.user!.id, username: username)
            
            let profile = await getLatestProfile(id: self.user!.id)
            
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
