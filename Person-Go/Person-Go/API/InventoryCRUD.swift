//
//  InventoryCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 20/05/2024.
//

import Foundation

public struct Inventory: Codable {
    let userID: UUID
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
        return inventory.first
    } catch {
        print("Failed to decode: \(error)")
        return nil
    }
}
