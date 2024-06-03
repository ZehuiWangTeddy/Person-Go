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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Notifications")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    .foregroundColor(Color("Text"))

                VStack(alignment: .leading, spacing: 20) {
                    Toggle(isOn: $enableNotifications) {
                        Text("Enable Notifications")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)

                    Picker("Notification Sound", selection: $notificationSound) {
                        Text("None").tag("None")
                        Text("Chime").tag("Chime")
                        Text("Alert").tag("Alert")
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
                    
                    // Testing Buttons
                    VStack(alignment: .leading, spacing: 20) {
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
                .padding(.horizontal)
            }
            .padding()
        }
        .background(Color("Background"))
        .navigationTitle("Notifications")
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

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
