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
