//
//  InventoryCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 20/05/2024.
//

import Foundation

public struct Inventory: Codable {
    let userID: UUID?
    let small: Int
    let medium: Int
    let large: Int

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
        var inventory = try! await fetchInventory(for: userId)
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
