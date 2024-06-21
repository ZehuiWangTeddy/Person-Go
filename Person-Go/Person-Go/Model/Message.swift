import Foundation

struct Message: Hashable, Decodable, Encodable {
    var messageId: Int
    var message: String
    var sentId: UUID
    var receiverId: UUID
    var sentAt: String
}

struct MessageSenderStruct: Hashable, Decodable, Encodable {
    var message: String
    var sentId: UUID
    var receiverId: UUID
    var sentAt: String
}
