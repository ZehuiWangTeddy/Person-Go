import SwiftUI

struct AddFriendsView: View {
    @State private var email: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var sizeClass

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 50) { // Increased spacing
                Text("Invite Your Friend")
                    .font(.largeTitle)
                    .padding(.top, sizeClass == .regular ? 20 : 0)

                VStack(alignment: .leading) { // Align VStack to the left
                    Text("Email")
                        .font(.headline)

                    TextField("Enter friend's email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Rounded edge text field
                }
                .padding(.bottom, sizeClass == .regular ? 80 : 0) // Add more space here
                .padding(.top, sizeClass == .regular ? 100 : 0)

                HStack {
                    Spacer()
                    Button(action: {
                        // Action to invite friend
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIGraphicsBeginImageContextWithOptions(geometry.size, false, 0)
                            UIApplication.shared.windows.first?.rootViewController?.view.drawHierarchy(in: CGRect(origin: .zero, size: geometry.size), afterScreenUpdates: true)
                            let image = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            // Use the image
                        }
                    }) {
                        Text("Invite")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: geometry.size.width / 2, height: geometry.size.height / 15)
                            .background(Color(hex: "#EC9583"))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.top, 15)

                Spacer()
            }
        }
        .padding(.horizontal)
        .background(colorScheme == .light ? Color(hex: "#F3EBD8") : Color(hex: "#271F0C"))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}