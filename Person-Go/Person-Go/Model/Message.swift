import Foundation


struct Message: Hashable, Decodable, Encodable {

    var message: String
    var sentId: UUID
    var receiverId: UUID
    var sentAt: String
}
