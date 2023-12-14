//
//  Functions.swift
//  Chat
//
//  Created by Apple on 11/10/23.
//

import Foundation
import SwiftUI
import AVFoundation
import PDFKit

func fetchVideoThumbnail(_ videoURL: URL, image: Binding<UIImage?>) {
    // Use URLSession to download the video data asynchronously
    URLSession.shared.dataTask(with: videoURL) { (data, response, error) in
        if let _ = data,
           let asset = try? AVAsset(url: videoURL),
           let imageGenerator = try? AVAssetImageGenerator(asset: asset) {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                DispatchQueue.main.async {
                    image.wrappedValue = UIImage(cgImage: cgImage)
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
            }
        }
    }.resume()
}

func generatePdfThumbnail(_ documentUrl: URL, image: Binding<UIImage?>) {
    let pdfDocument = PDFDocument(url: documentUrl)
    let pdfDocumentPage = pdfDocument?.page(at: 0)
    image.wrappedValue = pdfDocumentPage?.thumbnail(of: pdfDocumentPage?.bounds(for: .mediaBox).size ?? CGSize(width: 100, height: 100), for: PDFDisplayBox.trimBox)
}

func getFileSizeFromURL(urlString: String, completion: @escaping (Int64?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD" // Use HEAD method to get only the headers
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            if let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
               let fileSize = Int64(contentLength) {
                completion(fileSize)
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    task.resume()
}

func getBoolFromString(_ str: String?) -> Bool {
    return str != nil ? true : false
}

func getPhotoFromNSItemProvider(_ item: NSItemProvider, completion: @escaping (Result<Data, Error>) -> Void) {
    item.loadTransferable(type: Data.self) { result in
        switch result {
        case .success(let data):
            completion(.success(data))
        case .failure(let error):
            completion(.failure(error))
            print("Error fetching photo: \(error.localizedDescription)")
        }
    }
}

func getMediaFromNSItemProvider(_ itemProvider: NSItemProvider, typeIdentifier: String, completion: @escaping (Result<URL, Error>) -> Void) {
    itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
        if let error = error {
            print(error.localizedDescription)
        }
        
        guard let url = url else { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }
        
        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            
            try FileManager.default.copyItem(at: url, to: targetURL)
            
            completion(.success(targetURL))
        } catch {
            completion(.failure(error))
            print(error.localizedDescription)
        }
    }
}

func copyTextToClipboard(_ text: String?) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = text ?? ""
}

func saveImageToPhotos(urlString: String) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error downloading image: \(error)")
            return
        }

        guard let data = data, let image = UIImage(data: data) else {
            print("Invalid data or unable to create UIImage")
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Image saved to Photos")
    }

    task.resume()
}
