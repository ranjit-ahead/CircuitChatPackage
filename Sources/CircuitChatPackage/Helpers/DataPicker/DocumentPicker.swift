//
//  DocumentPicker.swift
//  Chat
//
//  Created by Apple on 09/10/23.
//

import Foundation
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocumentURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentTypes = [UTType.pdf.identifier, UTType.text.identifier, UTType.plainText.identifier, UTType.item.identifier] // Define the allowed document types
        
        let picker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Update the view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let selectedURL = urls.first {
                parent.selectedDocumentURL = selectedURL
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle document picker cancellation if needed
        }
    }
}

