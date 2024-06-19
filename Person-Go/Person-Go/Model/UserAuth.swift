import Foundation
import SwiftUI
import Supabase
import Combine
import NukeUI

class UserAuth: ObservableObject {
    @Published var isLoggedin = false
    @Published var user: Supabase.User?
    @Published var profile: Profile?
    
    private let session = URLSession(configuration: .default)
    private var userManager = UserManager()
    private var chatManager = ChatManager()

    func updateCurrentUser(user: Supabase.User)  {
        self.user = user
        
        Task {
            guard self.user != nil else {return}
            
            let profile = await getLatestProfile(id: self.user!.id)
            DispatchQueue.main.async {
                self.profile = profile
            }
//            do{
//                try await downloadImage(for: profile)
//            } catch {
//                print(error)
//            }
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
    
    @MainActor @ViewBuilder
    func getUserAvatar(width: CGFloat = 200, height: CGFloat = 200, radius: CGFloat = 100, padding: CGFloat = 30, edges: Edge.Set = .vertical) -> some View {
        let chatManager = ChatManager()
        
        if (profile == nil) || (profile != nil && profile!.avatarUrl == nil) {
            Image("userprofile")
                .resizable()
                .cornerRadius(radius)
                .frame(width: width, height: height)
                .padding(edges, padding)
        } else {

            if profile!.imageDataURL != nil {
                
                AsyncImage(url: profile!.imageDataURL!){ image in
                    image
                        .resizable()
                    //                    .scaledToFill()
                        .cornerRadius(radius)
                        .frame(width: width, height: height)
                        .padding(edges, padding)
                } placeholder: {
                    ProgressView()
                        .controlSize(.large)
                        .frame(width: width, height: height)
                }
                
            } else {
                LazyImage(url: chatManager.retrieveAvatarPublicUrl(path: profile!.avatarUrl!)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                        //                    .scaledToFill()
                            .cornerRadius(radius)
                            .frame(width: width, height: height)
                            .padding(edges, padding)
                    } else if state.error != nil {
                        AsyncImage(url: chatManager.getDefaultAvatar()){ image in
                            image.resizable().frame(width: 50, height: 50).cornerRadius(30)
                        } placeholder: {
                            ProgressView()
                                .controlSize(.large)
                                .frame(width: width, height: height)
                        }
                    } else {
                        ProgressView()
                           .controlSize(.large)
                           .frame(width: width, height: height)
                    }
                }
            }
        }
    }
    
//    func downloadImage(for profile: Profile) async throws {
//        guard profile.avatarUrl != nil else {
//            return;
//        }
//
//        let url = chatManager.retrieveAvatarPublicUrl(path: profile.avatarUrl!)
//
//        let (data, _) = try await session.data(from: url)
//        let dataURL = URL(string: "data:image/png;base64," + data.base64EncodedString())
//
//        DispatchQueue.main.async {
//            self.profile!.imageDataURL = dataURL
//        }
//    }
}
