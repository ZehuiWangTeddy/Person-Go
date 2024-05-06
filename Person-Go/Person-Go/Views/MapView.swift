import SwiftUI

struct MapView: View {
    @StateObject var mapViewContainer = MapViewContainer()

    var body: some View {
        ZStack {
            mapViewContainer.mapViewRepresentable
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button(action: {
                        mapViewContainer.mapViewRepresentable.makeCoordinator().zoomIn()
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
