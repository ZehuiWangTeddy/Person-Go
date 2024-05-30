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
    
    func getUserProfile(user: UUID) async -> Profile? {
        print("load friends...")
        
        do {
            let data: [Profile] = try await client.from("profiles")
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
}

