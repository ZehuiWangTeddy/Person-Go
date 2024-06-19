import Foundation
import Supabase

let encoder: JSONEncoder = {
    let encoder = PostgrestClient.Configuration.jsonEncoder
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

let decoder: JSONDecoder = {
    let decoder = PostgrestClient.Configuration.jsonDecoder
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

class ChatManager: NSObject, ObservableObject{
    
    let chatListChannelName = "chat-list"
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://" + apiUrl)!,
        supabaseKey: apiKey,
        options: SupabaseClientOptions(
            db: .init(encoder: encoder, decoder: decoder)
        )
    )
    
    @Published var friends = [Supabase.User]()
    
    override init(){
        super.init()
    }
    
    func parseDate(dateString: String) -> Date? {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = isoDateFormatter.date(from: dateString)
        
        if date == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: dateString)
        }
        
        return date
    }
    
    func getClient() -> SupabaseClient {
        return client
    }
    
    func fetchFriends(currentUser: Supabase.User) async -> [Friend] {
        print("load friends...")
        
        do {
            let data: [Friend] = try await client.from("friends_with_total_inventories")
                .select(
                    "*, profiles(*)")
                .eq("user_id", value: currentUser.id)
                .order("total_unread", ascending: false)
                .order("total_inventory", ascending: false)
                .execute()
                .value
            
            return data
        } catch {
            print(error)
            return []
        }
    }
    
    func fetchFriendInfo(id: UUID) async -> FriendInfo? {
        print("load friend profile...")
        
        do {
            let friends: [FriendInfo] = try await client.from("friends_with_different_inventories")
                .select()
                .eq("id", value: id)
                .execute()
                .value
            
            guard !friends.isEmpty else {
                return nil
            }
            
            return friends[0]
        } catch {
            return nil
        }
    }
    
    func fetchMessages(currentUser: Supabase.User, friendId: UUID) async -> [ChatMessage] {
        print("load messages... \(friendId) with \(currentUser.id)")
        do {
            let messages: [Message] = try await client.from("chats")
                .select(
                    "*")
                .in("sent_id", values: [currentUser.id, friendId])
                .in("receiver_id", values: [currentUser.id, friendId])
                .order("sent_at", ascending: true)
                .execute()
                .value
            
            var cmessages: [ChatMessage] = []
            
            for (index, message) in messages.enumerated() {
                cmessages.append(ChatMessage(message: message, type: .message))
                if (index + 1) % 5 == 0 {
                    cmessages.append(ChatMessage(message: Message(messageId: 0, message: " ", sentId: UUID(), receiverId: UUID(), sentAt: message.sentAt), type: .system))
                }
            }
            
            if !cmessages.isEmpty {
                await updateMessageAsReaded(lastMessageId: messages.last!.messageId, from: friendId, to: currentUser.id)
                
                cmessages.insert(ChatMessage(message: Message(messageId: 0, message: " ", sentId: UUID(), receiverId: UUID(), sentAt: messages.first!.sentAt), type: .system), at: 0)
            }
            
            return cmessages
        } catch {
            print(error)
            return []
        }
    }
    
    func updateMessageAsReaded(lastMessageId: Int, from: UUID, to: UUID) async {
        do {
            print("receiver_id: \(to), sent_id: \(from), message_id: \(lastMessageId)")
            try await client
                .from("chats")
                .update(["is_read": true])
                .eq("receiver_id", value: to)
                .eq("sent_id", value: from)
                .lte("message_id", value: lastMessageId)
                .execute()
        } catch {
            print("\(error)")
        }
    }
    
    func sendMessage(sentId: UUID, receiverId: UUID, content: String) async throws -> Message {
        let now = Date()
        
        // let dateFormatter = ISO8601DateFormatter()
        // dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]// ISO 8601格式
        // dateFormatter.timeZone = TimeZone.current
        
        // timestamptz time with current phone timezone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone.current
        
        let dateString = dateFormatter.string(from: now)
        let message = MessageSenderStruct(message: content, sentId: sentId, receiverId: receiverId, sentAt: dateString)
        
        return try await client.from("chats")
            .insert(message)
            .select()
            .single()
            .execute()
            .value
    }
    
    func clearChannel() {
        Task {
            print("close all channel...")
            _ = await client.removeAllChannels()
        }
    }
    
    func broadcastNewMessageEvent(channel: Supabase.RealtimeChannelV2, newMessage: Message) {
        Task {
            try await channel.broadcast(
                event: "new-message",
                message: [
                    "message": newMessage
                ]
            )
            
            let uchannel = await client.channel(newMessage.receiverId.uuidString)
            await uchannel.subscribe()
            try await uchannel.broadcast(
                event: "new-message",
                message: [
                    "from": newMessage.sentId
                ]
            )
        }
    }
    
    func getRoomChannel(u1: UUID, u2: UUID) -> String {
        let sortedUUIDs = [u1.uuidString, u2.uuidString].sorted().joined(separator: "-")
        
        let channelName = "Channel-\(sortedUUIDs)"
        
        return channelName
    }
    
    func retrieveAvatarPublicUrl(path: String) -> URL {
        
        do {
            let publicURL = try client.storage
                .from("avatars")
                .getPublicURL(
                    path: path
                    //                ,options: TransformOptions(
                    //                  width: 50,
                    //                  height: 50
                    //                )
                )
            
            return publicURL
        } catch {
            return URL(string: "https://ecqmicvfzypcomzptfbt.supabase.co/storage/v1/object/public/avatars/userprofile.png?t=2024-05-20T18%3A06%3A06.725Z")!
        }
    }
}

