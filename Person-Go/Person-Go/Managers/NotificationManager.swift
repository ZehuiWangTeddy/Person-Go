import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private override init() {
        super.init()
    }
    
    func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func configureNotificationSettings(enableSound: Bool, showPreviews: Bool, notificationSound: String) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            var options: UNNotificationPresentationOptions = []
            if enableSound {
                options.insert(.sound)
            }
            if showPreviews {
                options.insert(.alert)
            }
        }
    }
    
    func sendChatNotification(message: String, showPreviews: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "New Message"
        content.body = showPreviews ? message : "You have a new message"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func sendMissileNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Incoming Missile"
        content.body = "A missile is headed your way!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "missileSound.caf"))
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func registerDelegate() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // Testing Functions
    func testChatNotification() {
        sendChatNotification(message: "Test chat message", showPreviews: true)
    }
    
    func testMissileNotification() {
        sendMissileNotification()
    }
}
