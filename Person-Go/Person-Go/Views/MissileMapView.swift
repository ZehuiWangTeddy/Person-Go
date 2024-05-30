import SwiftUI
import MapKit
import CoreLocation

struct MissileMapView: View {
    @StateObject private var viewModel = MissileMapViewModel()

    var body: some View {
        VStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.missiles) { missile in
                MapMarker(coordinate: missile.coordinate, tint: .red)
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }
        }
    }
}

final class MissileMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var missiles: [Missile] = []

    private var locationManager: CLLocationManager?

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
        } else {
            print("Location services are not enabled")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            // Update missile coordinates relative to the user's location
            self.missiles = [
                Missile(name: "Quickstrike", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.0018, longitude: location.coordinate.longitude)),
                Missile(name: "Blaze Rocket", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.0027, longitude: location.coordinate.longitude)),
                Missile(name: "Phoenix Inferno", coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.0036, longitude: location.coordinate.longitude))
            ]
        }
    }
}

struct Missile: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
