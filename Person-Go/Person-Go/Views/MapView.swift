import SwiftUI
import Supabase
import MapKit

let supabase = SupabaseClient(supabaseURL: URL(string: "https://ecqmicvfzypcomzptfbt.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjcW1pY3ZmenlwY29tenB0ZmJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM3OTI1MTYsImV4cCI6MjAyOTM2ODUxNn0.PAGUfx8yBhzaXWa2g72G_udiuCjfMYezweu6EasRFg0")
var user_id = "1b73cd77-6a5d-4504-a00c-748f9a148058"

struct MapView: View {
    @StateObject var mapViewContainer = MapViewContainer()
    @ObservedObject var selectedFriendsStore: SelectedFriends

    init(selectedFriendsStore: SelectedFriends) {
        self.selectedFriendsStore = selectedFriendsStore
    }

    var body: some View {
        ZStack {
            mapViewContainer.mapViewRepresentable
                    .ignoresSafeArea()
                    .onAppear {
                        Task {
                            let locations = await fetchLocation()
                            let profiles = await fetchProfile()
                            let friends = await fetchFriends(for: UUID(uuidString: user_id)!)
                            compareAndAddAnnotations(for: locations, with: profiles, friends: friends)
                        }
                    }
.onChange(of: selectedFriendsStore.friends) { newValue in
    if !newValue.isEmpty {
        Task {
            await drawFlightPaths()
        }
    }
}
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button(action: {
                        mapViewContainer.mapViewRepresentable.makeCoordinator().zoomIn()
                    }) {
                        Image(systemName: "location.north")
                                .rotationEffect(.degrees(-30))
                                .padding()
                                .background(Color.white.opacity(0.75))
                                .clipShape(Circle())
                                .padding(.bottom)
                                .padding(.trailing)
                    }

                    // Add a new button to reload the map
                    Button(action: {
                        Task {
                            await reloadMap()
//                            await drawFlightPaths()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                                .padding()
                                .background(Color.white.opacity(0.75))
                                .clipShape(Circle())
                                .padding(.bottom)
                                .padding(.trailing)
                    }
                }
            }
        }
    }

    private func compareAndAddAnnotations(for locations: [Location], with profiles: [Profile], friends: [Friends]) {
    let friendIds = friends.map { $0.friendId }
    for location in locations {
        if friendIds.contains(location.userId), let matchingProfile = profiles.first(where: { $0.id == location.userId }) {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = matchingProfile.username ?? "No username"
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            mapViewContainer.mapViewRepresentable.mapView.addAnnotation(marker.annotation!)
//            mapViewContainer.mapViewRepresentable.drawFlightPath(to: coordinate)
        }
    }
}

    private func drawFlightPaths() async {
    let profiles = await fetchProfile()
    let locations = await fetchLocation()

    for friend in selectedFriendsStore.friends {
        if let matchingProfile = profiles.first(where: { $0.username == friend.name }),
           let matchingLocation = locations.first(where: { $0.userId == matchingProfile.id }) {
            let coordinate = CLLocationCoordinate2D(latitude: matchingLocation.latitude, longitude: matchingLocation.longitude)
            mapViewContainer.mapViewRepresentable.drawFlightPath(to: coordinate)
        }
    }
}

    func reloadMap() async {
    let locations = await fetchLocation()
    let profiles = await fetchProfile()
    let friends = await fetchFriends(for: UUID(uuidString: user_id)!)
    compareAndAddAnnotations(for: locations, with: profiles, friends: friends)
    await drawFlightPaths()
}
}

extension Friend: Equatable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.name == rhs.name && lhs.distance == rhs.distance && lhs.avatar == rhs.avatar
    }
}