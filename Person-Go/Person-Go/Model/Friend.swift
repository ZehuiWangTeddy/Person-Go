import SwiftUI
import MapKit

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let distance: Double
    let avatar: String
    let location: CLLocationCoordinate2D
}
