import Foundation
import Supabase

class InventoryManager {
    static let shared = InventoryManager()
    private let supabaseClient: SupabaseClient

    private init() {
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              let apiUrl = URL(string: apiUrlString),
              let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_URL and API_KEY must be set in Info.plist")
        }
        
        supabaseClient = SupabaseClient(supabaseURL: apiUrl, supabaseKey: apiKey)
    }

    func fetchInventory(for userID: UUID) async -> UserInventory? {
        do {
            let response: [UserInventory] = try await supabaseClient
                .from("inventory")
                .select()
                .eq("user_id", value: userID.uuidString)
                .execute()
                .value
            return response.first
        } catch {
            print("Error fetching inventory: \(error)")
            return nil
        }
    }

    func updateInventory(for userID: UUID, inventory: UserInventory) async -> Bool {
        do {
            try await supabaseClient
                .from("inventory")
                .update(["small": inventory.small, "medium": inventory.medium, "large": inventory.large])
                .eq("user_id", value: userID.uuidString)
                .execute()
            
            return true
        } catch {
            print("Error updating inventory: \(error)")
            return false
        }
    }
}
