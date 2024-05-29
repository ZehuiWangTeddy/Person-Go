import Foundation

struct Friend: Identifiable, Hashable, Decodable {
    var id: Int
    var name: String
    var friendId: UUID
    var distance: Double // Distance in kilometers
    var totalInventory: Int
    var profiles: Profile
}
