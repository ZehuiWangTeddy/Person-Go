
import SwiftUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var avatarImage: UIImage
    @Binding var isSelectImage: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(photoPicker: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let photoPicker: PhotoPicker
        
        init(photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
//                guard let data = image.jpegData(compressionQuality: 0.5),
//                      let compressimage = UIImage(data: data) else {
//                    // show error or alert
//                    return
//                 }
//                photoPicker.avatarImage = compressimage
                
                photoPicker.avatarImage = image
                photoPicker.isSelectImage = true
            } else {
                // return an error and show alert that choose not allow image
            }
            
            picker.dismiss(animated: true)
        }
    }
}
