import SwiftUI
import LocalAuthentication

struct SecurityView: View {
    @AppStorage("isFaceIDOrTouchIDEnabled") var isFaceIDOrTouchIDEnabled: Bool = false
    @AppStorage("unlockOption") var unlockOption: String = "Immediately"
    @AppStorage("appLockTime") var appLockTime: Int = 0 // Add this line
    @EnvironmentObject var appLockManager: AppLockManager // Inject AppLockManager

    let unlockOptions = ["Immediately", "After 1 minute", "After 15 minutes", "After 1 hour"]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Security")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            Divider()
            ScrollView {
                Toggle(isOn: $isFaceIDOrTouchIDEnabled) {
                    Text("Require Face ID or Touch ID")
                }
                .padding(.horizontal)
                .onChange(of: isFaceIDOrTouchIDEnabled) { newValue in
                    if newValue {
                        authenticate()
                    }
                }
                
                if isFaceIDOrTouchIDEnabled {
                    VStack {
                        ForEach(unlockOptions, id: \.self) { option in
                            Button(action: {
                                unlockOption = option
                                appLockManager.updateUnlockOption(option)
                            }) {
                                HStack {
                                    Text(option)
                                    Spacer()
                                    if unlockOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .contentShape(Rectangle()) // Make the entire row clickable
                                .padding(.horizontal) // Add horizontal padding to each option
                                .padding(.top, option == "Immediately" ? 10 : 0) // Add top padding to "Immediately"
                                .padding(.bottom, option == "After 1 hour" ? 10 : 0) // Add bottom padding to "After 1 hour"
                            }
                            Divider() // Add a border bottom under each option
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical) // Add vertical padding to the VStack
                    .transition(.slide) // Add a slide transition
                    .animation(.default) // Add a default animation
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID or Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isFaceIDOrTouchIDEnabled = true
                    } else {
                        isFaceIDOrTouchIDEnabled = false
                    }
                }
            }
        } else {
            // Device does not support Face ID or Touch ID
            isFaceIDOrTouchIDEnabled = false
        }
    }
}

#Preview {
    SecurityView()
}
