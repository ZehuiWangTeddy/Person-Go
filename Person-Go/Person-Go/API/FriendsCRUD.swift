//
//  FriendsCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 19/05/2024.
//

import Foundation

public struct FriendsForLaunchList: Identifiable, Decodable {
    public var id: UUID
    var username: String?
    var fullName: String?
    var avatarUrl: String?
    var userId: UUID?
    var latitude: Double?
    var longitude: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case userId = "user_id"
        case latitude
        case longitude
    }
}

public struct FriendsForMap: Identifiable, Decodable {
    public var id: UUID
    var latitude: Double?
    var longitude: Double?
    var username: String?
    var avatarUrl: String?
    var friendId: UUID?
    var userId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case username
        case avatarUrl = "avatar_url"
        case friendId = "friend_id"
        case userId = "user_id"
    }
}

public func fetchFriendsForLaunchList(for userId: UUID) async -> [FriendsForLaunchList]? {
    do {
        let friends: [FriendsForLaunchList] = try await supabase
            .from("friends_for_launch_list")
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

public func fetchFriendsForMap(for userId: UUID) async -> [FriendsForMap]? {
    do {
        let friends: [FriendsForMap] = try await supabase
            .from("friends_for_map")
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