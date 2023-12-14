//
//  ShowDocument.swift
//  Chat
//
//  Created by Apple on 20/10/23.
//

import SwiftUI
import PDFKit
import QuickLook
import UniformTypeIdentifiers

struct PDFKitView: UIViewRepresentable {

    let pdfDocument: PDFDocument

    init(showing pdfDoc: PDFDocument) {
        self.pdfDocument = pdfDoc
    }

    //you could also have inits that take a URL or Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdfDocument
    }
}

struct ShowDocument: View {
    
    var url: String
    
    var body: some View {
//        PDFKitView(showing: PDFDocument(url: URL(string: url)!)!)
//        DocumentViewer(url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!)
        PreviewController(url: URL(string: url)!)
    }
}

struct ShowDocument_Previews: PreviewProvider {
    static var previews: some View {
        ShowDocument(url: "http://snschatapp.s3.ap-south-1.amazonaws.com/uploads/media/2023/10/17/1697526899614-372102788.pdf")
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {}
    
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(
            in controller: QLPreviewController
        ) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            return parent.url as NSURL
        }
        
    }
}

