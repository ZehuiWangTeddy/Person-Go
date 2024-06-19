import SwiftUI
import UniformTypeIdentifiers
import Supabase
import PhotosUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userAuth: UserAuth
    
    // userManager
    let userManager = UserManager()
    let chatManager =  ChatManager()
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var currentAvatar: String = ""
    
    // file upload
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var imageData: Data?
    
    // Sheet
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Info"
    
    private func uploadFile(fileData: Data) async -> String {
        // get Image file type
        let type = avatarImage.debugDescription.split(separator: "(")[1].split(separator: ")")[0]
        
        let path = "uploads/" + UUID().uuidString + ".\(type)"
        do {
            let str = try await userManager.getClient().storage
                .from("avatars")
                .upload(
                    path: path,
                    file: fileData,
                    options: FileOptions(contentType: "application/octet-stream")
                )
            
            print(str)
            
            return path
        } catch {
            print("\(error)")
        }
        
        return ""
    }
    
    var body: some View {
        ZStack {
            Color("Background")
            VStack {
                
                if avatarImage != nil {
                    avatarImage?
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .padding(.vertical, 30)
                } else {
                    userAuth.getUserAvatar()
                }
                
                if #available(iOS 16.0, *) {
                    PhotosPicker("Select avatar", selection: $avatarItem, matching: .images)
                        .padding()
                        .onChange(of: avatarItem) { newItem in
                            Task {
                                if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                                    avatarImage = loaded
                                } else {
                                    print("Failed to load image as Image")
                                }
                                
                                if let loaded = try? await avatarItem?.loadTransferable(type: Data.self) {
                                    imageData = loaded
                                } else {
                                    print("Failed to load image as Data")
                                }
                            }
                        }
                    
                    if avatarItem != nil {
                        Button(action: {
                            avatarImage = nil
                            avatarItem = nil
                        }, label: {
                            Text("Clear")
                                .frame(maxWidth: .infinity)
                                .cornerRadius(4)
                        })
                    }
                } else {
                    Text("This feature requires iOS 16 or later")
                        .padding()
                }
                
                HStack {
                    Text("User Name")
                        .font(.title2)
                    Spacer()
                }
                TextField("New user name", text: $name)
                    .autocapitalization(.none)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Spacer().frame(height: 20)
                Button(action: {
                    Task {
                        let checkUsername = await userManager.checkUserNameIsAvaliable(name: name)
                        if !checkUsername {
                            showAlert.toggle()
                            alertTitle = "Error"
                            alertMessage = "Duplicate user name"
                            return
                        }
                        
                        if name.count < 3 {
                            showAlert.toggle()
                            alertTitle = "Error"
                            alertMessage = "Minimum 3 characters required"
                            return
                        }
                        
                        var filename = currentAvatar
                        if imageData != nil {
                            filename = await uploadFile(fileData: imageData!)
                        }
                        userAuth.updateUserProfile(username: name, filename: filename)
                        presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .cornerRadius(4)
                        .font(.title3)
                })
            }
            .padding()
        }
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
        .onAppear {
            self.name = userAuth.username()
            if userAuth.profile != nil && userAuth.profile!.avatarUrl != nil {
                self.currentAvatar = userAuth.profile!.avatarUrl!
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("Dismiss"))
            )
        }
    }
}
