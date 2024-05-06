import SwiftUI

struct InventoryView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Inventory")
                            .font(.system(size: 30)) // Increased font size
                            .fontWeight(.bold)
                            .padding(.bottom)
                    Divider()
                            .frame(height: 2) // Increase the height to make the divider thicker
                }
                        .padding(.bottom, 90) // Apply padding only to the bottom
                        .padding(.horizontal) // Add horizontal padding

                VStack(alignment: .leading) {
                    ForEach(["Small", "Medium", "Large"], id: \.self) { size in
                        HStack {
                            Image(systemName: "missile")
                                    .rotationEffect(.degrees(-45))
                            Text(size)
                                    .font(.system(size: 25))
                            Spacer() // Pushes the number to the right
                            Text("1") // Replace with actual number
                                    .font(.system(size: 25))

                        }
                        Divider()
                    }
                }
                        .padding(.horizontal) // Add horizontal padding

                Button(action: {
                    // Add your action here
                }) {
                    Text("Launch")
                            .font(.title)
                            .padding()
                            .background(Color(hex: "#EC9583")) // Change the background color to #EC9583
                            .foregroundColor(.white)
                            .cornerRadius(10)
                }
                        .padding(.top, 80) // Add some space above the button

                Spacer() // Pushes the VStack to the top
            }
        }
                .background(colorScheme == .light ? Color(hex: "#F3EBD8") : Color(hex: "#271F0C")) // Change the background color based on the color scheme
    }
}