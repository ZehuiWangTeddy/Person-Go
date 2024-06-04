import Foundation

public struct Launches: Encodable {
    var launchedAt: Date
    var userId: UUID
    var targetId: UUID
    var launchType: String

    enum CodingKeys: String, CodingKey {
        case launchedAt = "launched_at"
        case userId = "user_id"
        case targetId = "target_id"
        case launchType = "launch_type"
    }
}

public func InsertLaunches(launches: Launches) async throws {
    do {
        let _ = try await supabase
            .from("launches")
            .insert(launches)
            .execute()
    } catch {
        print("Failed to insert launches: \(error)")
    }
}