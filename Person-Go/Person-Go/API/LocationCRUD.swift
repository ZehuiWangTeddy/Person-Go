//
//  LocationCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 19/05/2024.
//

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

struct AnyEncodable: Encodable {
    let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: encoder)
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
        print("Location inserted successfully")
    } catch {
        print("Failed to insert location: \(error)")
    }
}


public func insertLaunch(user_id: UUID, target_id: UUID, launch_type: String) async {
    do {
        let _ = try await supabase
                .from("launches")
                .insert(launchData(user_id: user_id, target_id: target_id, launch_type: launch_type))
                .execute()
        print("Launch inserted successfully")
    } catch {
        print("Failed to insert launch: \(error)")
    }
}

public func deleteLaunch(launch_id: Int) async {
    do {
        let _ = try await supabase
                .from("launches")
                .delete()
                .eq("launch_id", value: launch_id)
                .execute()
        print("Launch deleted successfully")
    } catch {
        print("Failed to delete launch: \(error)")
    }
}
