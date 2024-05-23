//
//  ProfileCRUD.swift
//  Person-Go
//
//  Created by Atumah Gerald on 19/05/2024.
//

import Foundation


public struct Profile: Codable {
    let id: UUID
    let username: String?
}

public func fetchProfile() async -> [Profile] {
    do {
        let profiles: [Profile] = try await supabase
                .from("profiles")
                .select()
                .execute()
                .value
        return profiles
    } catch {
        print("Failed to decode: \(error)")
        return []
    }
}