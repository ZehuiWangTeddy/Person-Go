import Foundation



struct ChatMessage: Identifiable,Hashable,Decodable {
    
    enum MessageType: Decodable {
        case message
        case system
    }
    
    var id = UUID()
    var message: Message
    var type: MessageType
    
    func isUserMessage(uid: UUID) -> Bool {
        if (self.message.sentId == uid) {
            return true
        }
        
        return false
    }
}
