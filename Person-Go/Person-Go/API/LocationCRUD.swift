import Foundation

public struct Location: Codable {
    let userId: UUID
    let updatedAt: Date
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case updatedAt = "updated_at"
        case latitude
        case longitude
    }
}

public struct LaunchView: Codable {
    var user_id: UUID?
    var target_id: UUID?
    var longitude: Double?
    var latitude: Double?
    var username: String?
    var launcy_type: String?

    enum CodingKeys: String, CodingKey {
        case user_id
        case target_id
        case longitude
        case latitude
        case username
        case launcy_type
    }
}

public func fetchLocation() async -> [Location] {
    do {
        let locations: [Location] = try await supabase
            .from("locations")
            .select()
            .execute()
            .value
        return locations
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}

public func fetchSenderLocation(receiverId: UUID) async -> [LaunchView] {
    do {
        let launches: [LaunchView] = try await supabase
            .from("launch_view")
            .select()
            .eq("target_id", value: receiverId)
            .execute()
            .value
        return launches
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}

public struct launchData: Codable {
    var user_id: UUID?
    var target_id: UUID?
    var launch_type: String?
}

public struct locationData: Codable {
    var user_id: UUID?
    var latitude: Double?
    var longitude: Double?
}

public func insertLocation(user_id: UUID, latitude: Double, longitude: Double) async {
    do {
        let _ = try await supabase
            .from("locations")
            .upsert(locationData(user_id: user_id, latitude: latitude, longitude: longitude))
            .execute()
    } catch {
        print("Failed to insert location: \(error)")
    }
}


public func insertLaunch(user_id: UUID, target_id: UUID, launch_type: String) async -> Bool {
    do {
        let _ = try await supabase
            .from("launches")
            .insert(launchData(user_id: user_id, target_id: target_id, launch_type: launch_type))
            .execute()
        return true
    } catch {
        print("Failed to insert launch: \(error)")
        return false
    }
}

public func deleteLaunch(launch_id: Int) async {
    do {
        let _ = try await supabase
            .from("launches")
            .delete()
            .eq("launch_id", value: launch_id)
            .execute()
    } catch {
        print("Failed to delete launch: \(error)")
    }
}
