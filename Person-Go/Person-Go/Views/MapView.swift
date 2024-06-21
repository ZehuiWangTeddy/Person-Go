import SwiftUI
import Supabase
import MapKit
import Combine

let supabase = SupabaseClient(supabaseURL: URL(string: "https://" + apiUrl)!, supabaseKey: apiKey)

struct MapView: View {
    @StateObject var mapViewContainer = MapViewContainer()
    @ObservedObject var selectedFriendsStore: SelectedFriends
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining = 0
    @State private var receiverTimeRemaining = 0
    @State private var showTimer = false
    @State private var cancellables = Set<AnyCancellable>()
    @State var channel: Supabase.RealtimeChannelV2?
    @EnvironmentObject var userAuth: UserAuth
    @State var launch_id: AnyJSON?

    var user_id: String {
        return userAuth.user!.id.uuidString
    }

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
                            await updateSenderLocation()

                            if channel == nil {
                                await subscribeToLaunches()
                            }
                        }
                        selectedFriendsStore.$friends
                                .sink { newValue in
                                    if !newValue.isEmpty {

                                        Task {
                                            await drawFlightPaths()
                                            await addFriendsAsPins()
                                            await updateSenderLocation()
                                        }
                                        updateTimeRemaining()
                                        showTimer = true
                                    } else {
                                        showTimer = false
                                    }
                                }
                                .store(in: &cancellables)

                    }
                    .onDisappear {
                        Task {
                            if channel != nil {
                                await channel!.unsubscribe()
                                channel = nil
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
            let coordinate = CLLocationCoordinate2D(latitude: friend.latitude ?? 0, longitude: friend.longitude ?? 0)
            let polylineIdentifier = "\(launch_id)"
            let annotation = TimerAnnotation(coordinate: coordinate, title: friend.username ?? "", subtitle: "", countdown: timeRemaining, polylineIdentifier: polylineIdentifier) {
                self.mapViewContainer.mapViewRepresentable.removePolyline(identifier: polylineIdentifier)
            }
            annotation.startTimer()
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
                mapViewContainer.mapViewRepresentable.drawFlightPath(to: coordinate, color: .red, identifier: "\(launch_id)")

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
        case "Quickstrike":
            timeRemaining = 5
        case "Blaze Rocket":
            timeRemaining = 120
        case "Phoenix Inferno":
            timeRemaining = 180
        default:
            timeRemaining = 0
        }
    }

    func updateSenderLocation() async {
        let uuid = UUID(uuidString: user_id)
        if let uuid = uuid {
            let senderLocations = await fetchSenderLocation(receiverId: uuid)
            // Update the map with the new location data
            let allAnnotations = self.mapViewContainer.mapViewRepresentable.mapView.annotations

            for senderLocation in senderLocations {
                let coordinate = CLLocationCoordinate2D(latitude: senderLocation.latitude ?? 0, longitude: senderLocation.longitude ?? 0)
                let polylineIdentifier = "\(launch_id)"
                let annotation = TimerAnnotation(coordinate: coordinate, title: senderLocation.username ?? "", subtitle: "", countdown: timeRemaining, polylineIdentifier: polylineIdentifier) {
                    self.mapViewContainer.mapViewRepresentable.removePolyline(identifier: polylineIdentifier)
                }
                annotation.startTimer()
                self.mapViewContainer.mapViewRepresentable.mapView.addAnnotation(annotation)

                //                 Draw a flight path from the receiver to the sender
                mapViewContainer.mapViewRepresentable.drawFlightPath(to: coordinate, color: .blue, identifier: "\(launch_id)")
            }
        }
    }

    private func subscribeToLaunches() async {
        // Subscribe to the "launches" channel
        let channel = await supabase.channel("launches")
        let changes = await channel.postgresChange(AnyAction.self, schema: "public")
        await channel.subscribe()

        // Listen for changes and update the sender's location when a change occurs
        for await change in changes {
            switch change {
            case .insert(let action):
                launch_id = action.record["launch_id"]
                await updateSenderLocation()
            case .update(let action):
                await updateSenderLocation()
            case .delete(let action):
                print("Delete")
                await updateSenderLocation()
            case .select(let action):
                await updateSenderLocation()
            }
        }
    }
}

class TimerAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var countdown: Int
    var timer: Timer?
    var polylineIdentifier: String
    var removePolyline: (() -> Void)?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, countdown: Int, polylineIdentifier: String, removePolyline: @escaping () -> Void) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = "\(countdown)"
        self.countdown = countdown
        self.polylineIdentifier = polylineIdentifier
        self.removePolyline = removePolyline
        if self.countdown == 0 {
            self.subtitle = nil
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.countdown > 0 {
                self.countdown -= 1
                self.subtitle = "Time remaining: \(self.countdown) seconds"
            } else {
                self.subtitle = nil
                self.timer?.invalidate()
                self.timer = nil
                self.removePolyline?()
            }
        }
    }
}

class TimerAnnotationView: MKAnnotationView {
    var imageView: UIImageView?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupImageView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageView()
    }

    func setupImageView() {
        imageView = UIImageView(image: UIImage(systemName: "mappin.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal))
        if let imageView = imageView {
            imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // Change the width and height values to increase or decrease the size of the pin
            imageView.contentMode = .scaleAspectFit // Ensure the pin image scales correctly
            self.addSubview(imageView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

