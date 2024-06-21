import Combine
import UIKit

class AppLockManager: ObservableObject {
    @Published var isUnlocked: Bool = true
    private var lockTimeInterval: TimeInterval = 0.1
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    init() {
        isUnlocked = false
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        endBackgroundTask()
    }
    
    func updateUnlockOption(_ option: String) {
        switch option {
        case "Immediately":
            lockTimeInterval = 0.1
        case "After 1 minute":
            lockTimeInterval = 60
        case "After 15 minutes":
            lockTimeInterval = 15 * 60
        case "After 1 hour":
            lockTimeInterval = 60 * 60
        default:
            lockTimeInterval = 0
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnterBackground() {
        if lockTimeInterval > 0 {
            startBackgroundTask()
        }
    }
    
    @objc private func applicationWillEnterForeground() {
        endBackgroundTask()
    }
    
    private func startBackgroundTask() {
        guard backgroundTask == .invalid else { return }
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + lockTimeInterval) {
            self.lock()
        }
    }
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func lock() {
        isUnlocked = false
    }
    
}
