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

        let decoder = JSONDecoder()

        let friends = try decoder.decode([FriendsForMap].self, from: response.data)
        return friends
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}
