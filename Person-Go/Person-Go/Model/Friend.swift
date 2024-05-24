import Foundation

struct Friend: Identifiable, Hashable, Decodable {
    var id: Int
//    let id = UUID()
    var friendId: UUID
//    var name: String
//    var distance: Double
//    var avatar: String // Assume this is the name of an image in Assets.xcassets
    var totalInventory: Int
    
    var profiles: Profile
}


