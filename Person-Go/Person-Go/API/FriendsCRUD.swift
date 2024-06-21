//
//  FriendsCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 19/05/2024.
//

import Foundation

public struct FriendsForMap: Identifiable, Decodable {
    public var id: UUID
    var latitude: Double?
    var longitude: Double?
    var username: String?
    var avatar_url: String?
    var friend_id: UUID?
    var user_id: UUID?
}

public func fetchFriendsForMap(for userId: UUID) async -> [FriendsForMap]? {
    do {
        let response = try await supabase
                .from("friends_for_map")
                .select()
                .eq("user_id", value: userId)
                .execute()

//        print("JSON Response: \(response)")

        // Create a JSONDecoder
        let decoder = JSONDecoder()

        // Try to decode the JSON response into [FriendsForMap]
        let friends = try decoder.decode([FriendsForMap].self, from: response.data)
//        print(friends)
        return friends
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}