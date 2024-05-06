import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let mapView = MKMapView()
    let locationManager = LocationManager()
    @State var mapRegion = MKCoordinateRegion()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
//        uiView.setRegion(mapRegion, animated: true)
    }

    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}
extension MapViewRepresentable {
    class MapCoordinator: NSObject, MKMapViewDelegate{
        let parent: MapViewRepresentable
//        let locationManager = LocationManager()
        @State private var mapRegion = MKCoordinateRegion()

        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }

//        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
//                    longitude: userLocation.coordinate.longitude),
//                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//            parent.mapView.setRegion(region, animated: true)
//        }

        func zoomIn() {
            guard let userLocation = parent.locationManager.currentLocation else { return }
            let zoomedRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            mapRegion = zoomedRegion
            parent.mapView.setRegion(zoomedRegion, animated: true)
}
    }
}
