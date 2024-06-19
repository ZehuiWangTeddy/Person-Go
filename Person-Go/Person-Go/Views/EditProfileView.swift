import SwiftUI
import UniformTypeIdentifiers
import Supabase
import PhotosUI
import NukeUI

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
    @State private var avatarImage: UIImage = UIImage(named: "dog.png")!
    @State private var userprofile: String = ""
    @State private var isSelectedImage: Bool = false
    
    // Sheet
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Info"
    
    @State private var isShowingPhotoPicker = false
    
    private func uploadFile(fileData: Data) async -> String {
        
        let type = "jpg"
        
        let path = "uploads/" + UUID().uuidString + ".\(type)"
        print("image path:... \(path)")
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
                Group {
                    if !isSelectedImage && !self.userprofile.isEmpty {
                        LazyImage(url: chatManager.retrieveAvatarPublicUrl(path: self.userprofile)) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .cornerRadius(100)
                                    .frame(width: 200, height: 200)
                                    .padding(.vertical, 30)
                            } else if state.error != nil {
                                AsyncImage(url: self.chatManager.getDefaultAvatar()){ image in
                                    image.resizable().frame(width: 200, height: 200).cornerRadius(100).padding(.vertical, 30)
                                } placeholder: {
                                    ProgressView()
                                        .controlSize(.large)
                                        .frame(width: 200, height: 200)
                                }
                            } else {
                                ProgressView()
                                    .controlSize(.large)
                                    .frame(width: 200, height: 200)
                            }
                        }
                    } else {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(100)
                            .padding(.vertical, 30)
                    }
                }.onTapGesture { isShowingPhotoPicker.toggle() }
                
                if isSelectedImage {
                    Button(action: {
                        avatarImage = UIImage(named: "dog.png")!
                        isSelectedImage = false
                    }) {
                        Text("Clear")
                            .frame(width: 60, height: 10)
                            .padding()
                            .background(Color("Primary"))
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    Text("User Name")
                        .font(.title2)
                    Spacer()
                }
                TextField("new user name", text: $name)
                    .autocapitalization(.none)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Spacer().frame(height: 20)
                Button(action: {
                    Task {
                        let checkUsername = await userManager.checkUserNameIsAvaliable(user: userAuth.user!.id, name: name)
                        if !checkUsername {
                            showAlert.toggle()
                            alertTitle = "error"
                            alertMessage = "Duplicate user name"
                            return
                        }
                        
                        if name.count <= 3 {
                            showAlert.toggle()
                            alertTitle = "error"
                            alertMessage = "Minimum 3 characters required"
                            return
                        }
                        
                        var filename = currentAvatar;
                        
                        if isSelectedImage {
                            let idata = avatarImage.jpegData(compressionQuality: 0.5)
                            guard idata != nil else {
                                showAlert.toggle()
                                alertTitle = "error"
                                alertMessage = "Select image error, please try again later!"
                                return
                            }
                            filename = await uploadFile(fileData:idata!)
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
        .sheet(isPresented: $isShowingPhotoPicker, content: {
            PhotoPicker(avatarImage: $avatarImage, isSelectImage: $isSelectedImage)
        })
        .background(Color("Background"))
        .foregroundColor(Color("Text"))
        .onAppear {
            self.name = userAuth.username()
            if userAuth.profile != nil && userAuth.profile!.avatarUrl != nil {
                self.userprofile = userAuth.profile!.avatarUrl!
            }
            
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("dismiss"))
            )
        }
    }
}
