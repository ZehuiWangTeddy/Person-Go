import SwiftUI

@main
struct Person_GoApp: App {
    @StateObject var userAuth = UserAuth()

    var body: some Scene {
        WindowGroup {
            if userAuth.isLoggedin {
                ContentView()
            } else {
                LoginView()
                    .environmentObject(userAuth)
            }
        }
    }
}
