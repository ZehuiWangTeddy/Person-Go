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
            
            for message in messages {
                cmessages.append(ChatMessage(message: message))
            }
            
            return cmessages
        } catch {
            print(error)
            return []
        }
    }
    
    func sendMessage(sentId: UUID, receiverId: UUID, content: String) async throws -> Message {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateString = formatter.string(from: now)
        let message = Message(message: content, sentId: sentId, receiverId: receiverId, sentAt: dateString)
        
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
              .from("upload-avatars")
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

