import Foundation
import SwiftUI
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
    
    func updateUserProfile(username: String, filename: String?) {
        Task {
            guard self.user != nil else {return}
            
            _ = await userManager.updateUserProfile(user: self.user!.id, username: username, filename: filename)
            
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
    
    @ViewBuilder
    func getUserAvatar(width: CGFloat = 200, height: CGFloat = 200, radius: CGFloat = 100, padding: CGFloat = 30, edges: Edge.Set = .vertical) -> some View {
        let chatManager = ChatManager()
        
        if profile != nil && profile!.avatarUrl != nil {
            AsyncImage(url: chatManager.retrieveAvatarPublicUrl(path: profile!.avatarUrl!)){ image in
                image
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(radius)
                    .frame(width: width, height: height)
            } placeholder: {
                Image("userprofile")
                    .resizable()
                    .cornerRadius(radius)
                    .frame(width: width, height: height)
                    .padding(edges, padding)
            }
        } else {
            Image("userprofile")
                .resizable()
                .cornerRadius(radius)
                .frame(width: width, height: height)
                .padding(edges, padding)
        }
    }
}
