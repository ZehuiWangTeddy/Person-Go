import Foundation

struct ChatMessage: Identifiable, Hashable {
    var id = UUID()
    var content: String
    var isMyMessage: Bool
    var imageName: String
}
