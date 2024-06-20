import Foundation

struct FriendInfo: Identifiable, Hashable, Decodable {
    var id: UUID
    var email: String
    var username: String
    
    var avatarUrl: String?
    var small: Int
    var medium: Int
    var large: Int
}
