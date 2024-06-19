import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @Binding var isUnlocked: Bool
    @State private var biometricType: LABiometryType = .none

    var body: some View {
        VStack {
            Button(action: {
                authenticate()
            }) {
                Text(biometricType == .faceID ? "Unlock With Face ID" : "Unlock With Touch ID")
            }
            .padding()
            .background(Color("Primary"))
            .foregroundColor(.white)
            .cornerRadius(50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            checkBiometricType()
        }
    }

    func checkBiometricType() {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            biometricType = context.biometryType
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID or Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    }
                }
            }
        }
    }
}
