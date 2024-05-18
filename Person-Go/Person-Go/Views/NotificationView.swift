import SwiftUI

struct NotificationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var enableNotifications = true
    @State private var notificationSound = "Chime"
    @State private var showPreviews = true

    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Notifications")
                        .font(.system(size: 30)) // Increased font size
                        .fontWeight(.bold)
                        .padding(.bottom)
                    Divider()
                        .frame(height: 2) // Increase the height to make the divider thicker
                }
                .padding(.bottom, 90) // Apply padding only to the bottom
                .padding(.horizontal) // Add horizontal padding

                // Notification settings content
                VStack(alignment: .leading, spacing: 20) {
                    Toggle(isOn: $enableNotifications) {
                        Text("Enable Notifications")
                            .font(.headline)
                    }
                    .padding()

                    Picker("Notification Sound", selection: $notificationSound) {
                        Text("Chime").tag("Chime")
                        Text("Alert").tag("Alert")
                        Text("Silent").tag("Silent")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Toggle(isOn: $showPreviews) {
                        Text("Show Previews")
                            .font(.headline)
                    }
                    .padding()

                    Divider()

                    VStack(alignment: .leading) {
                        Text("Notification Preferences")
                            .font(.headline)
                            .padding(.bottom, 5)

                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("App Notifications")
                                    .font(.headline)
                                Text("Customize notifications for this app.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal) // Add horizontal padding
            }
            .padding()
        }
        .background(colorScheme == .light ? Color(hexString: "#F3EBD8") : Color(hexString: "#271F0C")) // Change the background color based on the color scheme
        .navigationTitle("Notifications")
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}

