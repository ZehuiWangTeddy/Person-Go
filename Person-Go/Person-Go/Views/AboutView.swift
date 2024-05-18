import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About Person Go")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                Text("Person Go is a revolutionary app that connects people through real-time location sharing. Our goal is to make it easier for friends and family to stay connected and meet up in person. With features like live location tracking, distance calculation, and easy-to-use interface, Person Go ensures you are always in touch with your loved ones.")
                    .font(.body)
                
                Text("Features")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                Text("""
                - Real-time location sharing
                - Distance calculation
                - Easy-to-use interface
                - Secure and private
                """)
                    .font(.body)

                Text("Our Mission")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                Text("Our mission is to bridge the gap between digital and physical interactions by making it easier for people to connect in person. We believe that real-world connections are essential for building strong relationships, and Person Go is designed to facilitate these connections.")
                    .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

