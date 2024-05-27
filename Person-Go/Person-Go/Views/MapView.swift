import SwiftUI
import Supabase
import MapKit
import Combine

let supabase = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)
var user_id = "1b73cd77-6a5d-4504-a00c-748f9a148058"

struct MapView: View {
    @StateObject var mapViewContainer = MapViewContainer()
    @ObservedObject var selectedFriendsStore: SelectedFriends
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining = 60
    @State private var showTimer = false
    @State private var cancellables = Set<AnyCancellable>()

    init(selectedFriendsStore: SelectedFriends) {
        self.selectedFriendsStore = selectedFriendsStore
    }

    var body: some View {
        ZStack {
            mapViewContainer.mapViewRepresentable
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        await fetchFriendsForMap(for: UUID(uuidString: user_id)!)
                        await addFriendsAsPins()
                    }
                    selectedFriendsStore.$friends
                        .sink { newValue in
                            if !newValue.isEmpty {

                                Task {
                                    await drawFlightPaths()
                                    await addFriendsAsPins()
                                }
                                updateTimeRemaining()
                                showTimer = true
                            } else {
                                showTimer = false
                            }
                        }
                        .store(in: &cancellables)
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


    func addFriendsAsPins() async {
    // Fetch friends for map
    let friendsForMap = await fetchFriendsForMap(for: UUID(uuidString: user_id)!) ?? []

    // Clear existing annotations
    let allAnnotations = self.mapViewContainer.mapViewRepresentable.mapView.annotations
    self.mapViewContainer.mapViewRepresentable.mapView.removeAnnotations(allAnnotations)

    // Add new annotations
    for friend in friendsForMap {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: friend.latitude ?? 0, longitude: friend.longitude ?? 0)
        annotation.title = friend.username
        self.mapViewContainer.mapViewRepresentable.mapView.addAnnotation(annotation)
    }
}



    private func drawFlightPaths() async {
    // Fetch friends for map
    let friendsForMap = await fetchFriendsForMap(for: UUID(uuidString: user_id)!) ?? []

    // Remove existing overlays
    mapViewContainer.mapViewRepresentable.mapView.removeOverlays(mapViewContainer.mapViewRepresentable.mapView.overlays)

    for friend in selectedFriendsStore.friends {
        if let matchingFriend = friendsForMap.first(where: { $0.username == friend.name }) {
            let coordinate = CLLocationCoordinate2D(latitude: matchingFriend.latitude ?? 0, longitude: matchingFriend.longitude ?? 0)
            mapViewContainer.mapViewRepresentable.drawFlightPath(to: coordinate)

            // Draw radius
            let radius = getRadius()
            let circle = MKCircle(center: coordinate, radius: radius)
            mapViewContainer.mapViewRepresentable.mapView.addOverlay(circle)
        }
    }
}

    private func getRadius() -> CLLocationDistance {
        switch selectedFriendsStore.selectedSize {
        case "Quickstrike":
            return 100 // 100m
        case "Blaze Rocket":
            return 500 // 500m
        case "Phoenix Inferno":
            return 1000 // 1km
        default:
            return 0
        }
    }

func reloadMap() async {
    // Fetch friends for map
    let friendsForMap = await fetchFriendsForMap(for: UUID(uuidString: user_id)!) ?? []

    // Clear existing annotations
    let allAnnotations = self.mapViewContainer.mapViewRepresentable.mapView.annotations
    self.mapViewContainer.mapViewRepresentable.mapView.removeAnnotations(allAnnotations)

    // Add new annotations
    await addFriendsAsPins()

    // Draw flight paths
    await drawFlightPaths()
}

    private func updateTimeRemaining() {
        switch selectedFriendsStore.selectedSize {
        case "Small":
            timeRemaining = 60
        case "Medium":
            timeRemaining = 120
        case "Large":
            timeRemaining = 180
        default:
            timeRemaining = 0
        }
    }
}


