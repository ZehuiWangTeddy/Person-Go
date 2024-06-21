import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func printCurrentLocation() {
        if let location = currentLocation {
            print("Current coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        } else {
            print("Location not available")
        }
    }
    
    var currentLocation: CLLocation? {
        return locationManager.location
    }
    
    func calculateDistance(from userLocation: CLLocation, to friendLocation: CLLocation) -> Double {
        let distanceInMeters = userLocation.distance(from: friendLocation)
        let distanceInKilometers = distanceInMeters / 1000
        printCurrentLocation()
        
        return distanceInKilometers
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else {
            return
        }
        locationManager.stopUpdatingLocation()
    }
}
