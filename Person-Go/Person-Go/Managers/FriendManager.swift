import SwiftUI
import MapKit
import Supabase

class FriendManager: ObservableObject {
    @Published var friends: [Friend] = []
    @State var supabase: SupabaseClient

    struct Profile: Decodable {
        let id: String
        let username: String
    }

    init() {
        self.supabase = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
        Task {
            await fetchFriends()
        }
        self.friends = [
            Friend(name: "Joe", distance: 1.5, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0322)),
            Friend(name: "John", distance: 1.8, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0323)),
            Friend(name: "Selena", distance: 2.5, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
            Friend(name: "Taylor", distance: 2.8, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
            Friend(name: "Lennox", distance: 3.5, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        ]
    }

    private func fetchFriends() async {
        do {
            let response: [String] = try await supabase
                .rpc("get_friends", params: ["p_uuid": "1b73cd77-6a5d-4504-a00c-748f9a148058"])
                .execute()
                .value
            for uuid in response {
                print("UUID: \(uuid)")
                let friend: [Profile] = try await supabase
                .from("profiles")
                .select("id,username")
                .execute()
                .value
                print(friend)
            }
        } catch {
            print(error)
        }
    }
}
