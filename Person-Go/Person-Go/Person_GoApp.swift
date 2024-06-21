import SwiftUI

let apiUrl: String = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String

@main
struct Person_GoApp: App {
    @StateObject var userAuth = UserAuth()
    @StateObject var locationManager = LocationManager()

    init() {
        // Register notification delegate
        NotificationManager.shared.registerDelegate()

        // Request notification permissions
        NotificationManager.shared.requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            if userAuth.isLoggedin {
                ContentView()
                        .environmentObject(userAuth)
                        .onAppear {
                            // Configure notification settings as an example
                            NotificationManager.shared.configureNotificationSettings(enableSound: true, showPreviews: true, notificationSound: "Chime")
                            // Start location updates
                            startLocationUpdates()
                        }
            } else {
                LoginView()
                        .environmentObject(userAuth)
            }
        }
    }

    func startLocationUpdates() {
        Task {
            while true {
                guard let currentLocation = locationManager.currentLocation else {
                    print("Current location is not available.")
                    return
                }
                await insertLocation(user_id: UUID(uuidString: userAuth.user!.id.uuidString)!, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                do {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                } catch {
                    print("Failed to sleep.")
                }
            }
        }
    }
}
