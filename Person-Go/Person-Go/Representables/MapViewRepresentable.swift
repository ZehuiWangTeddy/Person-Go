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
        uiView.delegate = context.coordinator
    }

    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }

    func addAnnotationToMap(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

    func drawFlightPath(to destination: CLLocationCoordinate2D) {
        guard let sourceLocation = locationManager.currentLocation else {
            return
        }
        let sourceCoordinate = sourceLocation.coordinate
        let polyline = MKPolyline(coordinates: [sourceCoordinate, destination], count: 2)
        mapView.addOverlay(polyline)
    }

    class MapCoordinator: NSObject, MKMapViewDelegate {
        let parent: MapViewRepresentable
        @State private var mapRegion = MKCoordinateRegion()

        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = .red // Change the color to red
                renderer.lineDashPattern = [2, 5] // Make the line dashed
                renderer.lineWidth = 2
                return renderer
            } else if overlay is MKCircle {
                let renderer = MKCircleRenderer(overlay: overlay)
                renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let timerAnnotation = annotation as? TimerAnnotation else {
                return nil
            }

            let identifier = "TimerAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = TimerAnnotationView(annotation: timerAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = timerAnnotation
            }

            annotationView?.subviews.forEach { $0.removeFromSuperview() }

            let label = UILabel()
            label.text = timerAnnotation.title
            label.sizeToFit()

            label.frame = CGRect(x: -20, y: 10, width: label.frame.width, height: label.frame.height)

            annotationView?.addSubview(label)

            if let timerAnnotationView = annotationView as? TimerAnnotationView {
                timerAnnotationView.setupImageView()
            }

            return annotationView
        }

        func zoomIn() {
            guard let userLocation = parent.locationManager.currentLocation else { return }
            let zoomedRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            parent.mapView.setRegion(zoomedRegion, animated: true)
        }
    }
}
