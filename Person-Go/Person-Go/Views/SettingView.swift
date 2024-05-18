import SwiftUI

struct SettingView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Setting")
                                .font(.system(size: 30)) // Increased font size
                                .fontWeight(.bold)
                                .padding(.bottom)
                        Divider()
                                .frame(height: 2) // Increase the height to make the divider thicker
                    }
                            .padding(.bottom, 90) // Apply padding only to the bottom
                            .padding(.horizontal) // Add horizontal padding

                    VStack(alignment: .leading) {
                        ForEach(["Notification", "Security", "About"], id: \.self) { size in
                            if size == "Security" {
                                NavigationLink(destination: SecurityView()) {
                                    Text(size)
                                            .font(.system(size: 25))
                                }
                                .padding()
                                .background(Color.clear) // Make the button background transparent
                                .foregroundColor(.primary) // Use the primary color for the text
                            } else if size == "About" {
                                NavigationLink(destination: AboutView()) {
                                    
                                    Text(size)
                                            .font(.system(size: 25))
                                }
                                .padding()
                                .background(Color.clear) // Make the button background transparent
                                .foregroundColor(.primary) // Use the primary color for the text
                            } else if size == "Notification" {
                                NavigationLink(destination: NotificationView()) {
                                Text(size)
                                .font(.system(size: 25))
                                }
                                .padding()
                                .background(Color.clear) // Make the button background transparent
                                .foregroundColor(.primary) // Use the primary color for the text
                            }
                            Divider()
                        }
                    }
                            .padding(.horizontal) // Add horizontal padding

                    Button(action: {
                        // Add your action here
                    }) {
                        Text("Log out")
                                .font(.title)
                                .padding()
                                .background(Color(hex: "#EC9583")) // Change the background color to #EC9583
                                .foregroundColor(.white)
                                .cornerRadius(10)
                    }
                            .padding(.top, 80) // Add some space above the button
                }
            }
                    .background(colorScheme == .light ? Color(hex: "#F3EBD8") : Color(hex: "#271F0C")) // Change the background color based on the color scheme
        }
    }
}
