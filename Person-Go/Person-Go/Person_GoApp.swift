import SwiftUI

let apiUrl: String = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String

@main
struct Person_GoApp: App {
    @StateObject var userAuth = UserAuth()

    var body: some Scene {
        WindowGroup {
            if userAuth.isLoggedin {
                ContentView()
                    .environmentObject(userAuth)
            } else {
                LoginView()
                    .environmentObject(userAuth)
            }
        }
    }
}
