import SwiftUI
import MapKit

class FriendManager: ObservableObject {
    @Published var friends: [Friend] = []

    init() {
        self.friends = [
            Friend(name: "Joe", distance: 1.5, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0322)),
            Friend(name: "John", distance: 1.8, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0323)),
            Friend(name: "Selena", distance: 2.5, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
            Friend(name: "Taylor", distance: 2.8, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
            Friend(name: "Lennox", distance: 3.5, avatar: "userprofile", location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        ]
    }
}
