import SwiftUI

struct NotificationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var enableNotifications = true
    @State private var notificationSound = "Chime"
    @State private var showPreviews = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Notifications")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    .foregroundColor(Color("Text"))

                // Notification settings content
                VStack(alignment: .leading, spacing: 20) {
                    Toggle(isOn: $enableNotifications) {
                        Text("Enable Notifications")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)

                    Picker("Notification Sound", selection: $notificationSound) {
                        Text("Chime").tag("Chime")
                        Text("Alert").tag("Alert")
                        Text("Silent").tag("Silent")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)

                    Toggle(isOn: $showPreviews) {
                        Text("Show Previews")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notification Preferences")
                            .font(.headline)
                            .padding(.bottom, 5)
                            .foregroundColor(Color("Text"))

                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("App Notifications")
                                    .font(.headline)
                                    .foregroundColor(Color("Text"))
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
                .padding(.horizontal)
            }
            .padding()
        }
        .background(Color("Background"))
        .navigationTitle("Notifications")
        .foregroundColor(Color("Text"))
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
