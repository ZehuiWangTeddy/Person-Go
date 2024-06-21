import Foundation


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
