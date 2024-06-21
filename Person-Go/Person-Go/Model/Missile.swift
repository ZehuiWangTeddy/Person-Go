import Foundation
import CoreLocation

struct Missile: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
