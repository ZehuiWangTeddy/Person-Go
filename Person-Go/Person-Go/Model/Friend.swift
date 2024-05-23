import Foundation

struct Friend: Identifiable, Hashable, Decodable {
    var id: Int
//    let id = UUID()
    var friendId: UUID
    let name: String
    let distance: Double
    let avatar: String // Assume this is the name of an image in Assets.xcassets
    var totalInventory: Int
    
    var profiles: Profile
}


