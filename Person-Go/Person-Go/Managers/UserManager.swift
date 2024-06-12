import Foundation
import Supabase

class UserManager: NSObject, ObservableObject{
    
    
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
}

