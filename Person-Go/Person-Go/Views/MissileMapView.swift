import SwiftUI
import MapKit
import CoreLocation

struct MissileMapView: View {
    @StateObject private var viewModel = MissileMapViewModel()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.missiles) { missile in
                MapAnnotation(coordinate: missile.coordinate) {
                    VStack {
                        Text(missile.name)
                            .font(.caption)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .onTapGesture {
                        viewModel.getDirections(to: missile.coordinate, targetMissile: missile)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }

            if let route = viewModel.route {
                MapPolyline(route: route)
            }
        }
    }
}

struct MapPolyline: UIViewRepresentable {
    var route: MKRoute

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.addOverlay(route.polyline)
        uiView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 64, left: 32, bottom: 64, right: 32), animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapPolyline

        init(_ parent: MapPolyline) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

final class MissileMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var missiles: [Missile] = []
    @Published var route: MKRoute?

    private var locationManager: CLLocationManager?
    private var userLocation: CLLocationCoordinate2D?
    private var targetMissile: Missile?

    override init() {
        super.init()
        checkIfLocationServicesIsEnabled()
    }

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
        } else {
            print("Location services are not enabled")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location authorization denied or restricted")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

            // Check if user has reached the target missile location
            if let targetMissile = self.targetMissile {
                let missileLocation = CLLocation(latitude: targetMissile.coordinate.latitude, longitude: targetMissile.coordinate.longitude)
                let userLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let distance = missileLocation.distance(from: userLocation)

                if distance < 10 { // Distance threshold in meters
                    self.addMissileToInventory(targetMissile)
                    self.targetMissile = nil // Reset target missile
                }
            }

            // Update missile coordinates relative to the user's location
            self.missiles = [
                Missile(name: "Quickstrike", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.0001, longitude: location.coordinate.longitude)),
                Missile(name: "Blaze Rocket", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.0002, longitude: location.coordinate.longitude)),
                Missile(name: "Phoenix Inferno", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.0003, longitude: location.coordinate.longitude))
            ]
        }
    }

    func getDirections(to destination: CLLocationCoordinate2D, targetMissile: Missile) {
        guard let userLocation = userLocation else { return }
        self.targetMissile = targetMissile

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let response = response else { return }

            if let route = response.routes.first {
                DispatchQueue.main.async {
                    self.route = route
                }
            }
        }
    }

    private func addMissileToInventory(_ missile: Missile) {
        guard let userID = UUID(uuidString: "user_id") else { return }
        
        Task {
            if var inventory = await InventoryManager.shared.fetchInventory(for: userID) {
                switch missile.name {
                case "Quickstrike":
                    inventory.small += 1
                case "Blaze Rocket":
                    inventory.medium += 1
                case "Phoenix Inferno":
                    inventory.large += 1
                default:
                    return
                }
                
                let success = await InventoryManager.shared.updateInventory(for: userID, inventory: inventory)
                if success {
                    print("\(missile.name) added to inventory")
                } else {
                    print("Failed to update inventory")
                }
            }
        }
    }
}
