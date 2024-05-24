import SwiftUI

struct InventoryView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @State private var selectedSize: String? = nil // State to track selected size
//    @State private var navigateToLaunchListView = false // State to trigger navigation
//
//    let missileData = [
//        ("Quickstrike", "5km"),
//        ("Blaze Rocket", "10km"),
//        ("Phoenix Inferno", "50km")
//    ]

    var body: some View {
        Text("misile")
//        NavigationStack { // Use NavigationStack instead of NavigationView
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("Inventory")
//                        .font(.largeTitle)
//                        .bold()
//                        .padding(.bottom, 0)
//                        .foregroundColor(Color("Text"))
//                    Divider()
//                        .frame(height: 2)
//                    
//                    VStack(alignment: .leading) {
//                        ForEach(missileData, id: \.0) { missile, range in
//                            HStack {
//                                Image(systemName: "missile")
//                                    .rotationEffect(.degrees(-45))
//                                    .foregroundColor(Color("Text"))
//                                VStack(alignment: .leading) {
//                                    Text(missile)
//                                        .font(.title2)
//                                        .foregroundColor(Color("Text"))
//                                    Text("Max Range: \(range)")
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                }
//                                Spacer()
//                                Text("1") // Replace with actual number
//                                    .font(.title2)
//                                    .foregroundColor(Color("Text"))
//                            }
//                            .padding()
//                            .background(self.selectedSize == missile ? Color.gray.opacity(0.2) : Color.clear)
//                            .cornerRadius(8)
//                            .onTapGesture {
//                                self.selectedSize = missile
//                            }
//                            Divider()
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    Button(action: {
//                        if selectedSize != nil {
//                            navigateToLaunchListView = true
//                        }
//                    }) {
//                        Text("Launch")
//                            .font(.title3)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(selectedSize != nil ? Color("Primary") : Color.gray)
//                            .foregroundColor(Color("Text"))
//                            .cornerRadius(10)
//                    }
//                    .padding(.top, 40)
//                    .disabled(selectedSize == nil)
//                }
//                .padding()
//            }
//            .background(Color("Background"))
//            .navigationBarHidden(true)
//            .navigationDestination(isPresented: $navigateToLaunchListView) {
//                LaunchListView()
//            }
//        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
