import Foundation

struct ChatMessage: Identifiable,Hashable,Decodable {
    var id = UUID()
    var message: Message

    func isUserMessage(uid: UUID) -> Bool {
        if (self.message.sentId == uid) {
            return true
        }
        
        return false
    }
}
