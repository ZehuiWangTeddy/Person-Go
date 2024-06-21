import Foundation

public struct Inventory: Codable {
    let userID: UUID?
    var small: Int
    var medium: Int
    var large: Int
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case small
        case medium
        case large
    }
}


public func fetchInventory(for userId: UUID) async -> Inventory? {
    do {
        let inventory: [Inventory] = try await supabase
            .from("inventories")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        print("Fetched inventory: \(inventory)")
        return inventory.first
    } catch {
        print("Failed to decode: \(error)")
        return nil
    }
}

public struct AnyEncodable: Encodable {
    let value: Encodable
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

public func decreaseInventory(for userId: UUID, missileType: String) async -> Bool {
    do {
        let inventory = try! await fetchInventory(for: userId)
        switch missileType {
        case "Quickstrike":
            let newSmallCount = (inventory?.small ?? 0) - 1
            let _ = try await supabase
                .from("inventories")
                .update(["small": newSmallCount])
                .eq("user_id", value: userId.uuidString)
                .execute()
            print("Inventory updated")
            return true
            
        case "Blaze Rocket":
            let newMediumCount = (inventory?.medium ?? 0) - 1
            let _ = try await supabase
                .from("inventories")
                .update(["medium": newMediumCount])
                .eq("user_id", value: userId.uuidString)
                .execute()
            print("Inventory updated")
            return true
            
        case "Phoenix Inferno":
            let newLargeCount = (inventory?.large ?? 0) - 1
            let _ = try await supabase
                .from("inventories")
                .update(["large": newLargeCount])
                .eq("user_id", value: userId.uuidString)
                .execute()
            print("Inventory updated")
            return true
        default:
            print("Inventory not updated")
            return false
        }
    } catch {
        print("Failed to update inventory: \(error)")
        return false
    }
    
}

public func incrementInventoryItem(for userId: UUID, item: String, increment: Int = 1) async throws -> Bool {
    do {
        // Fetch the current inventory for the user
        guard let currentInventory = try await fetchInventory(for: userId) else {
            print("No existing inventory for user ID: \(userId)")
            return false
        }
        
        // Ensure fetched values are handled safely with nil coalescing operator
        let currentSmall = currentInventory.small ?? 0
        let currentMedium = currentInventory.medium ?? 0
        let currentLarge = currentInventory.large ?? 0
        
        // Initialize new counts with current values
        var newSmall = currentSmall
        var newMedium = currentMedium
        var newLarge = currentLarge
        
        // Adjust the appropriate inventory count
        switch item {
        case "small":
            newSmall += increment
        case "medium":
            newMedium += increment
        case "large":
            newLarge += increment
        default:
            print("Invalid item specified")
            return false
        }
        
        // Perform the update with new values
        let updatedRows = try await supabase
            .from("inventories")
            .update([
                "small": newSmall,
                "medium": newMedium,
                "large": newLarge
            ])
            .eq("user_id", value: userId)
            .execute()
        
        print("Updated inventory for user ID: \(userId).")
        
        // Check if any rows were actually updated
        return (updatedRows.count ?? 0) > 0 // Safely handle the optional count
    } catch {
        print("Failed to increment inventory: \(error)")
        throw error
    }
}
