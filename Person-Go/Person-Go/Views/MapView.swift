import SwiftUI

struct MapView: View {
    @State var mapViewRepresentable: MapViewRepresentable

    var body: some View {
        ZStack {
            mapViewRepresentable
                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        mapViewRepresentable.zoomIn()
                    }) {
                        Image(systemName: "location.north")
                            .rotationEffect(.degrees(-30))
                            .padding()
                            .background(Color.white.opacity(0.75))
                            .clipShape(Circle())
                            .padding(.bottom)
                            .padding(.trailing)
                    }
                }
            }
        }
    }
}

#Preview {
    MapView(mapViewRepresentable: MapViewRepresentable(locationManager: LocationManager()))
}
