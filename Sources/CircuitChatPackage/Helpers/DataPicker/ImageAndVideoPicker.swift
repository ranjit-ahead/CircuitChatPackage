//
//  ImageAndVideoPicker.swift
//  Chat
//
//  Created by Apple on 09/10/23.
//

import Foundation
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct ImageAndVideoPicker: UIViewControllerRepresentable {
    
    @Binding var selectedImageURL: [URL]
    @Binding var selectedVideoURL: URL?
    
    @Binding var isPickerPresented: Bool
    
    @Binding var showMediaSelected: Bool
    
    var allowEditing = false

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
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
        let parent: ImageAndVideoPicker
        
        init(_ parent: ImageAndVideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let imageURL = info[.imageURL] as? URL {
                parent.selectedImageURL.append(imageURL)
            } else if let videoURL = info[.mediaURL] as? URL {
                parent.selectedVideoURL = videoURL
            }
            parent.isPickerPresented = false
            parent.showMediaSelected = true
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPickerPresented = false
        }
    }
}
