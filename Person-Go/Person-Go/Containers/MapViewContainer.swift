import SwiftUI
import MapKit

class MapViewContainer: ObservableObject {
    @Published var mapViewRepresentable: MapViewRepresentable

    init() {
        self.mapViewRepresentable = MapViewRepresentable()
    }
}
