import SwiftUI

struct AboutView: View {
    var appVersion: String = "1.0.0" // Replace with your app's current version
    var creationYear: String = "2024" // Replace with your app's creation year

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About Person Go")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    .foregroundColor(Color("Text"))

                Text("Person Go is a revolutionary app that connects people through real-time location game and chats. Our goal is to make it easier for friends and family to stay connected and have fun playing the missile game. With features like missile launch, distance calculation, and easy-to-use interface, Person Go ensures you are always in touch with your loved ones and having fun.")
                    .font(.body)
                    .foregroundColor(Color("Text"))
                
                Text("Features")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                    .foregroundColor(Color("Text"))

                Text("""
                - Real-time chat
                - Distance Missile game
                - Easy-to-use interface
                - Secure and private
                """)
                    .font(.body)
                    .foregroundColor(Color("Text"))

                Text("Our Mission")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                    .foregroundColor(Color("Text"))

                Text("Our mission is to bridge the gap between digital and physical interactions by making it easier for people to connect and have fun. We believe that real-world connections are essential for building strong relationships, and Person Go is designed to facilitate these connections.")
                    .font(.body)
                    .foregroundColor(Color("Text"))

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("App Version: \(appVersion)")
                        .font(.subheadline)
                        .foregroundColor(Color("Text"))

                    HStack(spacing: 5) {
                        Text("©")
                        Text(creationYear)
                        Text("PersonGo Inc")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("Text"))

                    Button(action: {
                        // Add your update check action here
                    }) {
                        Text("Check for Updates")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Primary"))
                            .foregroundColor(Color("Text"))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color("Background"))
        .navigationTitle("About")
        .foregroundColor(Color("Text"))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
