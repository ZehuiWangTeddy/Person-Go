import SwiftUI

let apiUrl: String = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String

@main
struct Person_GoApp: App {
    @StateObject var userAuth = UserAuth()
    
    init() {
        // Register notification delegate
        NotificationManager.shared.registerDelegate()
        
        // Request notification permissions
        NotificationManager.shared.requestNotificationPermissions()
        
        URLCache.shared.memoryCapacity = 10 * 1024 * 1024   // 100MB
        URLCache.shared.diskCapacity = 20 * 1024 * 1024     // 200MB
        URLSession.shared.configuration.requestCachePolicy = .returnCacheDataElseLoad
    }
    
    var body: some Scene {
        WindowGroup {
            if userAuth.isLoggedin {
                ContentView()
                    .environmentObject(userAuth)
                    .onAppear {
                        // Configure notification settings as an example
                        NotificationManager.shared.configureNotificationSettings(enableSound: true, showPreviews: true, notificationSound: "Chime")
                    }
            } else {
                LoginView()
                    .environmentObject(userAuth)
            }
        }
    }
}
