import SwiftUI
import SDWebImageSwiftUI

struct MissileClaimedView: View {
    let gifName: String
    let missileName: String
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all) // Ensure background color fills the entire view
            
            VStack {
                Text("\(missileName) claimed successfully")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(Color("Text"))
                AnimatedImage(name: gifName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
                Spacer()
            }
            .padding()
        }
    }
}
