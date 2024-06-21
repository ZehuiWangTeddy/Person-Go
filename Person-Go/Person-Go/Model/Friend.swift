import Foundation

struct Friend: Identifiable, Hashable, Decodable {
    var id: Int
    var friendId: UUID
    var totalInventory: Int
    var totalUnread: Int
    var profiles: Profile
}

extension Friend {
    func username() -> String {
        let profile = self.profiles
        
        guard profile.username != nil else { return "" }
        
        return profile.username!
    }
}
