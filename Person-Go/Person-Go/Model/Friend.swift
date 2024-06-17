import Foundation

struct Friend: Identifiable, Hashable, Decodable {
    var id: Int
    //    let id = UUID()
    var friendId: UUID
    //    var name: String
    //    var distance: Double
    //    var avatar: String // Assume this is the name of an image in Assets.xcassets
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
