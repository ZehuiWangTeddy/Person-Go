import SwiftUI

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let distance: Double
    let avatar: String // Assume this is the name of an image in Assets.xcassets
}
