import SwiftUI

struct SettingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showLoginView = false
    @EnvironmentObject var userAuth: UserAuth
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Settings")
                                .font(.largeTitle)
                                .bold()
                            Divider()
                                .frame(height: 2)
                        }
                        .padding(.bottom, 0)
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            ForEach(["Notification", "Security", "About"], id: \.self) { item in
                                if item == "Security" {
                                    NavigationLink(destination: SecurityView()) {
                                        Text(item)
                                            .font(.title2)
                                            .padding()
                                    }
                                    .background(Color.clear)
                                    .foregroundColor(Color("Text"))
                                } else if item == "Notification" {
                                    NavigationLink(destination: NotificationView()) {
                                        Text(item)
                                            .font(.title2)
                                            .padding()
                                    }
                                    .background(Color.clear)
                                    .foregroundColor(Color("Text"))
                                } else if item == "About" {
                                    NavigationLink(destination: AboutView()) {
                                        Text(item)
                                            .font(.title2)
                                            .padding()
                                    }
                                    .background(Color.clear)
                                    .foregroundColor(Color("Text"))
                                }
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            showLoginView = true
                        }) {
                            Text("Log out")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("Primary"))
                                .foregroundColor(Color("Text"))
                                .cornerRadius(4)
                        }
                        .fullScreenCover(isPresented: $showLoginView) {
                            LoginView()
                        }
                        .padding(.top, 40)
                    }
                    .padding()
                }
                .background(Color("Background"))
            }
        }
    }
}

#Preview {
    SettingView()
}
