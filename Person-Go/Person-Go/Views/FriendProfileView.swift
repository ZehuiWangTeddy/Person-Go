import SwiftUI

struct FriendProfileView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView { // Wrap the VStack in a ScrollView
            VStack {
                Image(systemName: "person.crop.circle.fill") // System image as a placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.top, 50) // More space at the top

                VStack {
                    VStack(alignment: .leading) {
                        Text("Username")
                            .font(.title)
                            .padding(.bottom)
                        Divider()

                        Text("Email")
                            .font(.title)
                            .padding(.bottom)
                        Divider()

                        Text("Small")
                            .font(.title)
                            .padding(.bottom)
                        Divider()

                        Text("Medium")
                            .font(.title)
                            .padding(.bottom)
                        Divider()

                        Text("Large")
                            .font(.title)
                            .padding(.bottom)
                        Divider()
                    }
                    .padding()
                }
                .padding(.top, 50) // More space between the profile picture and the text

                Spacer() // Pushes the content to the top
            }
        }
        .background(colorScheme == .light ? Color(hex: "#F3EBD8") : Color(hex: "#271F0C")) // Use the dynamic color
        .edgesIgnoringSafeArea(.all) // Make sure the background color fills the entire screen
    }
}

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}