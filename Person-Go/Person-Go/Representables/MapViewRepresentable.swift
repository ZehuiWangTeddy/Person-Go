import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    let mapView = MKMapView()
    var friendManager = FriendManager()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        for friend in friendManager.friends {
            let annotation = MKPointAnnotation()
            annotation.coordinate = friend.location
            annotation.title = friend.name
            uiView.addAnnotation(annotation)
        }

        if let location = locationManager.currentLocation {
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            uiView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }

    func zoomIn() {
        (mapView.delegate as? MapCoordinator)?.zoomIn()
    }
}

extension MapViewRepresentable {
    class MapCoordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }

        func zoomIn() {
            guard let userLocation = parent.locationManager.currentLocation else { return }
            let zoomedRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            parent.mapView.setRegion(zoomedRegion, animated: true)
        }
    }
}
