import SwiftUI
import SDWebImageSwiftUI

struct TestView: View {
    @Binding var inventory: UserInventory // Bind to the inventory in the main view
    let userId: UUID // Pass the logged-in user's ID
    @StateObject private var locationManager = LocationManager()
    @State private var selectedItemType: String? = nil
    @State private var showAdditionalButtonSmall = false
    @State private var showAdditionalButtonMedium = false
    @State private var showAdditionalButtonLarge = false
    @State private var showCelebration = false

    let missileData = [
        ("Quickstrike", "Walk 50m", "quickstrike.gif", "small"),
        ("Blaze Rocket", "Walk 100m", "blaze_rocket.gif", "medium"),
        ("Phoenix Inferno", "Walk 150m", "phoenix_inferno.gif", "large")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Task Completion")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 0)
                            .foregroundColor(Color("Text"))
                        Divider()
                            .frame(height: 2)

                        VStack(alignment: .leading) {
                            Text("Distance moved: \(locationManager.distanceMoved, specifier: "%.2f") meters")
                                .padding()
                                .font(.headline)
                                .foregroundColor(Color("Text"))

                            if selectedItemType == nil {
                                Text("Complete a task to get Missiles!")
                                    .font(.headline)
                                    .padding()
                                    .foregroundColor(Color("Text"))

                                ForEach(missileData, id: \.0) { missile, distance, imageName, itemType in
                                    Button(action: {
                                        selectedItemType = itemType
                                        locationManager.resetDistanceMoved()
                                        locationManager.startDistanceCalculation()
                                    }) {
                                        HStack {
                                            missileImage(imageName: imageName)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .padding(.trailing, 8)
                                            VStack(alignment: .leading) {
                                                Text(missile)
                                                    .font(.title2)
                                                    .foregroundColor(.black)
                                                Text(distance)
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(8)
                                    }
                                }
                            } else {
                                if selectedItemType == "small" && showAdditionalButtonSmall {
                                    Button(action: {
                                        Task {
                                            await claimMissile(item: "small", imageName: "quickstrike.gif", message: "Quickstrike")
                                        }
                                    }) {
                                        HStack {
                                            missileImage(imageName: "quickstrike.gif")
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .padding(.trailing, 8)
                                            VStack(alignment: .leading) {
                                                Text("Claim Quickstrike")
                                                    .font(.title2)
                                                    .foregroundColor(.black)
                                                Text("Walk 50m")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(8)
                                    }
                                }

                                if selectedItemType == "medium" && showAdditionalButtonMedium {
                                    Button(action: {
                                        Task {
                                            await claimMissile(item: "medium", imageName: "blaze_rocket.gif", message: "Blaze Rocket")
                                        }
                                    }) {
                                        HStack {
                                            missileImage(imageName: "blaze_rocket.gif")
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .padding(.trailing, 8)
                                            VStack(alignment: .leading) {
                                                Text("Claim Blaze Rocket")
                                                    .font(.title2)
                                                    .foregroundColor(.black)
                                                Text("Walk 100m")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(8)
                                    }
                                }

                                if selectedItemType == "large" && showAdditionalButtonLarge {
                                    Button(action: {
                                        Task {
                                            await claimMissile(item: "large", imageName: "phoenix_inferno.gif", message: "Phoenix Inferno")
                                        }
                                    }) {
                                        HStack {
                                            missileImage(imageName: "phoenix_inferno.gif")
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .padding(.trailing, 8)
                                            VStack(alignment: .leading) {
                                                Text("Claim Phoenix Inferno")
                                                    .font(.title2)
                                                    .foregroundColor(.black)
                                                Text("Walk 150m")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                .background(Color("Background"))
                .navigationBarItems(trailing: Button(action: {
                    // Navigate back or perform another action
                }) {
                    Text("Back")
                        .foregroundColor(Color("Primary"))
                })

                if showCelebration {
                    VStack {
                        Text("Missile Claimed!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .transition(.scale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showCelebration = false
                        }
                    }
                }
            }
        }
        .onChange(of: locationManager.distanceMoved) { newDistance in
            if selectedItemType == "small" && newDistance >= 50 && !showAdditionalButtonSmall {
                showAdditionalButtonSmall = true
            }
            if selectedItemType == "medium" && newDistance >= 100 && !showAdditionalButtonMedium {
                showAdditionalButtonMedium = true
            }
            if selectedItemType == "large" && newDistance >= 150 && !showAdditionalButtonLarge {
                showAdditionalButtonLarge = true
            }
        }
    }

    private func missileImage(imageName: String) -> some View {
        if let _ = Bundle.main.path(forResource: imageName, ofType: nil) {
            return AnyView(AnimatedImage(name: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit))
        } else {
            return AnyView(Text("Image not found")
                .foregroundColor(.red)
                .frame(width: 50, height: 50))
        }
    }

    func incrementInventoryItemForUser(userId: UUID, item: String) async -> Bool {
        do {
            let success = try await incrementInventoryItem(for: userId, item: item)
            if success {
                switch item {
                case "small":
                    inventory.small += 1
                case "medium":
                    inventory.medium += 1
                case "large":
                    inventory.large += 1
                default:
                    break
                }
                return true
            } else {
                print("Failed to increment inventory item.")
                return false
            }
        } catch {
            print("Error incrementing inventory: \(error)")
            return false
        }
    }

    func claimMissile(item: String, imageName: String, message: String) async {
        let success = await incrementInventoryItemForUser(userId: userId, item: item)
        if success {
            withAnimation {
                showCelebration = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showCelebration = false
                }
            }
        }
        switch item {
        case "small":
            showAdditionalButtonSmall = false
        case "medium":
            showAdditionalButtonMedium = false
        case "large":
            showAdditionalButtonLarge = false
        default:
            break
        }
        selectedItemType = nil
        locationManager.stopDistanceCalculation()
        locationManager.resetDistanceMoved()
    }
}
