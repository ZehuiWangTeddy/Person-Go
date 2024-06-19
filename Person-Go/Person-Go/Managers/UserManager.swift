import Foundation
import Supabase

class UserManager: NSObject, ObservableObject{
    
    protocol AnyType {}
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://" + apiUrl)!,
        supabaseKey: apiKey,
        options: SupabaseClientOptions(
            db: .init(encoder: encoder, decoder: decoder)
        )
    )

    func getClient() -> SupabaseClient
    {
        return client
    }
    
    func getUserProfile(user: UUID) async -> Profile? {
        print("load profile...")
        
        do {
            let data: [Profile] = try await client
                .from("profiles")
                .select()
                .eq("id", value: user)
                .execute()
                .value
            
            if (data.isEmpty) {
                return nil
            }
            
            return data.first
        } catch {
            print(error)
            return nil
        }
    }
    
    func updateUserProfile(user: UUID, username: String, filename: String?) async -> Bool {
        var datas = [
            "username": username
        ]
        
        if filename != nil {
            datas["avatar_url"] = filename
        }
        do {
            try await client
              .from("profiles")
              .update(datas)
              .eq("id", value: user)
              .execute()
            
            return true
        } catch {
            print(error)
//            return nil
            
            return false
        }
    }
    
    func checkUserNameIsAvaliable(user: UUID, name: String) async -> Bool {
        do {
            let data: [Profile] = try await client
                .from("profiles")
                .select()
                .eq("username", value: name)
                .execute()
                .value
            
            if (data.isEmpty) {
                return true
            }
            
            let profile = data.first!
            
            if (profile.id == user) {
                return true
            }
            
            return false
        } catch {
            print(error)
            return false
        }
    }
    
    func findUserByEmail(email: String) async -> UUID? {
        do {
            let data: [Profile] = try await client
                .from("users_view")
                .select("id")
                .eq("email", value: email)
                .execute()
                .value
            
            if (data.isEmpty) {
                return nil
            }
            
            return data.first?.id
        } catch {
            print(error)
            return nil
        }
    }
    
    func isFriendAlready(user: UUID, friend: UUID) async -> Bool {
        do {
            let data: [Profile] = try await client
                .from("friends")
                .select("id")
                .eq("user_id", value: user)
                .eq("friend_id", value: friend)
                .execute()
                .value
            
            if (data.isEmpty) {
                return false
            }
            
            return true
        } catch {
            print(error)
            return true
        }
    }
    
    func addFriendShip(user: UUID, friend: UUID) async -> Bool {
        struct FriendShip :Encodable {
            let userId: UUID
            let friendId: UUID
        }
        
        let friendships = [
            FriendShip(userId: user, friendId: friend),
            FriendShip(userId: friend, friendId: user),
        ]

        do {
            try await supabase
                .from("friends")
                .insert(friendships)
                .execute()
            
            return true
        } catch {
            print(error)
            return false
        }
    }
}

