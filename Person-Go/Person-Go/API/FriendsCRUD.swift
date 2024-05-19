//
//  FriendsCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 19/05/2024.
//

import Foundation

public struct Friends: Codable {
    let userId: UUID
    let friendId: UUID

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case friendId = "friend_id"
    }
}

public func fetchFriends() async -> [Friends] {
    do {
        let friends: [Friends] = try await supabase
            .from("friends")
            .select()
            .execute()
            .value
        return friends
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}

public func fetchFriends(for userId: UUID) async -> [Friends] {
    do {
        let friends: [Friends] = try await supabase
            .from("friends")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        return friends
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}