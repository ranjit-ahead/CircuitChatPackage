//
//  ImagePicker.swift
//  Chat
//
//  Created by Apple on 21/09/23.
//

import Foundation
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImageURL: URL?
    @Binding var isImagePickerPresented: Bool
    
    var allowEditing = false

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = [UTType.image.identifier]
        picker.allowsEditing = allowEditing ? true : false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Update the view controller if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let imageURL = info[.imageURL] as? URL {
                parent.selectedImageURL = imageURL
            }
            parent.isImagePickerPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
    }
}
