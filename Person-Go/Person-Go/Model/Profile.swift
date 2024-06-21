import Foundation

public struct Profile: Hashable, Decodable {
    var id: UUID
    var username: String?
    var fullName: String?
    var avatarUrl: String?
}
