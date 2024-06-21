import CoreLocation
import Combine

class TaskViewViewLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var distanceMoved: Double = 0.0
    @Published var currentLocation: CLLocation?
    private var lastLocation: CLLocation?
    @Published var isCalculatingDistance: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 0.01  // meters
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isCalculatingDistance, let newLocation = locations.last else { return }

        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            distanceMoved += distance
            print("Moved distance: \(distance) meters, Total distance: \(distanceMoved) meters")
        } else {
            print("Starting location tracking at: \(newLocation.coordinate)")
        }

        lastLocation = newLocation
        currentLocation = newLocation
    }

    func resetDistanceMoved() {
        distanceMoved = 0.0
        lastLocation = currentLocation
    }
    
    func startDistanceCalculation() {
        isCalculatingDistance = true
    }
    
    func stopDistanceCalculation() {
        isCalculatingDistance = false
    }
}
