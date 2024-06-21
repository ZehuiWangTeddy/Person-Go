import SwiftUI

struct NotificationView: View {
    @State private var enableNotifications = true {
        didSet {
            if enableNotifications {
                NotificationManager.shared.requestNotificationPermissions()
            }
        }
    }
    @State private var notificationSound = "Chime" {
        didSet {
            configureNotificationSettings()
        }
    }
    @State private var showPreviews = true {
        didSet {
            configureNotificationSettings()
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Notifications")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle(isOn: $enableNotifications) {
                        Text("Enable Notifications")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    Picker("Notification Sound", selection: $notificationSound) {
                        Text("None").tag("None")
                        Text("Chime").tag("Chime")
                        Text("Alert").tag("Alert")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle(isOn: $showPreviews) {
                        Text("Show Previews")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Text("Notification Preferences")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .foregroundColor(Color("Text"))
                    
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("App Notifications (Coming Soon)")
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
                    
                    Button(action: {
                        NotificationManager.shared.testChatNotification()
                    }) {
                        Text("Test Chat Notification")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        NotificationManager.shared.testMissileNotification()
                    }) {
                        Text("Test Missile Notification")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
        .onAppear {
            configureNotificationSettings()
        }
    }
    
    private func configureNotificationSettings() {
        let enableSound = notificationSound != "None"
        NotificationManager.shared.configureNotificationSettings(enableSound: enableSound, showPreviews: showPreviews, notificationSound: notificationSound)
    }
}

#Preview {
    NotificationView()
}
