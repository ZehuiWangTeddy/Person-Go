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
    @State private var celebrationGif: String?

    let missileData = [
        ("Quickstrike", "Walk 50m", "quickstrike.gif", "small", "Quickstrike_walking.gif"),
        ("Blaze Rocket", "Walk 100m", "blaze_rocket.gif", "medium", "Blaze_rocket_walking.gif"),
        ("Phoenix Inferno", "Walk 150m", "phoenix_inferno.gif", "large", "Phoenix_inferno_walking.gif")
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

                                ForEach(missileData, id: \.0) { missile, distance, imageName, itemType, _ in
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
                                displayGif()
                                if selectedItemType == "small" && showAdditionalButtonSmall {
                                    Button(action: {
                                        Task {
                                            await claimMissile(item: "small", imageName: "quickstrike.gif", message: "Quickstrike", celebrationGif: "Quickstrike_celebration.gif")
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
                                            await claimMissile(item: "medium", imageName: "blaze_rocket.gif", message: "Blaze Rocket", celebrationGif: "Blaze_rocket_celebration.gif")
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
                                            await claimMissile(item: "large", imageName: "phoenix_inferno.gif", message: "Phoenix Inferno", celebrationGif: "Phoenix_inferno_celebration.gif")
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
                            .padding(.bottom, 10)

                        if let celebrationGif = celebrationGif {
                            AnimatedImage(name: celebrationGif)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .padding()
                        }
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

    private func displayGif() -> some View {
        let gifName: String
        switch selectedItemType {
        case "small":
            gifName = "Quickstrike_walking.gif"
        case "medium":
            gifName = "Blaze_rocket_walking.gif"
        case "large":
            gifName = "Phoenix_inferno_walking.gif"
        default:
            gifName = ""
        }
        return gifName.isEmpty ? AnyView(EmptyView()) : AnyView(
            AnimatedImage(name: gifName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding()
        )
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

    func claimMissile(item: String, imageName: String, message: String, celebrationGif: String) async {
        let success = await incrementInventoryItemForUser(userId: userId, item: item)
        if success {
            withAnimation {
                self.celebrationGif = celebrationGif
                showCelebration = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showCelebration = false
                    self.celebrationGif = nil
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
