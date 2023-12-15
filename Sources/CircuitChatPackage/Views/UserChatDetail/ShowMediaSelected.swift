//
//  ShowMediaSelected.swift
//  Chat
//
//  Created by Apple on 21/11/23.
//

import SwiftUI
import PhotosUI
import AVKit

class SelectedMedia: ObservableObject {
    @Published var items = [MediaObject]()
    
    func append(item: MediaObject) {
        items.append(item)
    }
    
    func deleteAll() {
        items.removeAll()
    }
}

class MediaObject: Equatable, Identifiable {
    
    static func == (lhs: MediaObject, rhs: MediaObject) -> Bool {
        return lhs.mediaData == rhs.mediaData
    }
    
    var mediaResult: PHPickerResult
    var mediaItem: NSItemProvider?
    var mediaIdentifier: String?
    var mediaType = ""
    var mediaExtension = ""
    var mediaData: Data?
    var mediaURL: URL?
    var mediaText = ""
    
    init(_ result: PHPickerResult) {
        mediaResult = result
        
        mediaItem = result.itemProvider
        mediaIdentifier = mediaItem?.registeredTypeIdentifiers.first ?? ""
    }

}

struct ShowMediaSelected: View {
    
    @Binding var selectedMedia: SelectedMedia
    
    @EnvironmentObject var observed: UserChatDetailObserved
    
    var userDetails: Chat?
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    @State private var galleryURL: URL?
    @State private var openGallery = false
    
    @State private var cropImage = false
    @State private var editImage = false
    @State private var currentImage = 0
    
    @Binding var openShowEditView: Bool
    
//    @State private var editingStack: EditingStack?
    
//    @Binding var imageData: [Data]
    @Binding var mediaText: String
    
    var body: some View {
        VStack {
            if editImage {
                VStack {
//                    if let editingStack = editingStack {
//                        SwiftUIClassicImageEditView(editingStack: editingStack) {
//                            let data = try! editingStack.makeRenderer().render().makeOptimizedForSharingData(dataType: .png)
//                            imageData.remove(at: currentImage)
//                            imageData.insert(data, at: currentImage)
//                            editImage.toggle()
//                        } onCancel: {
//                            editImage.toggle()
//                        }
//                    }
                }
            } else if cropImage {
                VStack {
//                    if let editingStack = editingStack {
//                        SwiftUIPhotosCropView(editingStack: editingStack) {
//                            let data = try! editingStack.makeRenderer().render().makeOptimizedForSharingData(dataType: .png)
//                            imageData.remove(at: currentImage)
//                            imageData.insert(data, at: currentImage)
//                            cropImage.toggle()
//                        } onCancel: {
//                            cropImage.toggle()
//                        }
//                    }
                }
            } else {
                HStack {
                    Button(action: {
                        // Handle button tap if needed
                        openShowEditView.toggle()
                    }) {
                        Image(systemName: "multiply")
                            //.font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
//                            .padding()
                    }.frame(width: 36, height: 36).padding()
                    Spacer()
                    Button(action: {
                        // Handle button tap if needed
                        editImage.toggle()
                    }) {
                        Image(systemName: "circle.grid.3x3.circle")
                            //.font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
//                            .padding()
                    }.frame(width: 36, height: 36).padding()
                    Button(action: {
                        // Handle button tap if needed
                        cropImage.toggle()
                    }) {
                        Image(systemName: "crop.rotate")
                            //.font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
//                            .padding()
                    }.frame(width: 36, height: 36).padding()
                }
                Spacer()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedMedia.items) { mediaObject in
                            MediaVC(selectedMedia: $selectedMedia, mediaObject: mediaObject)
                                .frame(width: UIScreen.screenWidth)
                                .frame(maxHeight: .infinity)
                        }
                    }
                }
                //PageVC(selectedMedia: selectedMedia, currentImage: $currentImage)
                
                Spacer()
                VStack(alignment: .trailing, spacing: 32) {
                    HStack {
                        Button {
//                            openGallery.toggle()
                        } label: {
                            Image(systemName: "plus.rectangle.on.rectangle").foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.96)).padding(.leading, 11)
                        }
                        .fullScreenCover(isPresented: $openGallery, content: {
                            PhotoPicker(mediaItems: $selectedMedia) { didSelectItem in
                                // Handle didSelectItems value here...
                                openGallery = false
                            }
                        })
                        
                        TextField("", text: $mediaText)
                            .foregroundColor(.white)
                            .placeholder(when: mediaText.isEmpty) {
                                Text("Add a caption...")
                                    .font(.regularFont(14))
                                    .foregroundColor(Color(red: 0.97, green: 0.97, blue: 0.97))
                            }
                    }
                    .frame(minHeight: 42)
                    .background {
                        Rectangle()
                            .foregroundColor(Color(red: 0, green: 0, blue: 0))
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.69, green: 0.69, blue: 0.69), lineWidth: 1)
                            )
                    }
                    
                    Button(action: sendMessage) {
                        Image("sendIcon", bundle: .module)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipped()
                    }
                }
                
//                Group {
//                    if let imageData = self.imageData, imageData.count == 1 {
//                        if let firstImage = imageData.first {
//                            Image(uiImage: UIImage(data: firstImage)!)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: UIScreen.main.bounds.size.width, height: 250)
//                                    .background(Color.black)
//                        }
//                    } else {
//                        PageViewController(pages: imageData.map{
//                            ShowData(data: $0)
//                        }, currentPage: $currentImage).frame(width: UIScreen.main.bounds.size.width, height: 250)
//                    }
//                }
                Spacer()
            }
        }
        .onAppear {
//            do {
//                let imageProvider = try ImageProvider(data: imageData[currentImage])
//                self.editingStack = EditingStack(imageProvider: imageProvider)
//            } catch _ as NSError {
//                print("fail")
//            }
        }
        .onChange(of: currentImage, perform: { currentImg in
//            do {
//                let imageProvider = try ImageProvider(data: imageData[currentImg])
//                self.editingStack = EditingStack(imageProvider: imageProvider)
//            } catch _ as NSError {
//                print("fail")
//            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        //.edgesIgnoringSafeArea(.all)
        
    }
    
    func sendMessage() {
        if let userDetails = userDetails {
            observed.sendMessage(selectedMedia: selectedMedia, to: userDetails.id, contentType: "media", receiverType: userDetails.chatType ?? "user")
            selectedMedia = SelectedMedia()
            openShowEditView.toggle()
        }
    }
}


struct MediaVC: View {
    @Binding var selectedMedia: SelectedMedia
    var mediaObject: MediaObject
    
    @State private var imageData: Data?
    
    @State private var videoUrl: URL?
    
    var body: some View {
        VStack {
            if let imageData = imageData {
                Image(uiImage: UIImage(data: imageData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color.black)
            } else if let videoUrl = videoUrl {
                VideoPlayer(player: AVPlayer(url: videoUrl))
            }
        }
        .background(Color.black)
        .onAppear {
            Task {
                if let utType = UTType(mediaObject.mediaIdentifier ?? "") {
                    if utType.conforms(to: .image) {
//                        getPhotoFromNSItemProvider(mediaObject.mediaItem!, completion: { result in
//                            switch result {
//                            case .success(let data):
//                                imageData = data
//                                if let index = selectedMedia.items.firstIndex(of: mediaObject) {
//                                    selectedMedia.items[index].mediaData = data
//                                    selectedMedia.items[index].mediaType = "image"
//                                    if let pathExtension = URL(dataRepresentation: data, relativeTo: nil)?.lastPathComponent {
//                                        selectedMedia.items[index].mediaExtension = pathExtension
//                                    }
//                                }
//                            case .failure(let error):
//                                print("Error fetching photo: \(error.localizedDescription)")
//                            }
//                        })
                        getMediaFromNSItemProvider(mediaObject.mediaItem!, typeIdentifier: mediaObject.mediaIdentifier ?? "", completion: { result in
                            switch result {
                            case .success(let url):
                                do {
                                    imageData = try Data(contentsOf: url)
                                } catch _ {
                                    print("Error")
                                }
                                if let index = selectedMedia.items.firstIndex(of: mediaObject) {
                                    selectedMedia.items[index].mediaURL = url
                                    selectedMedia.items[index].mediaType = "image"
                                    selectedMedia.items[index].mediaExtension = url.pathExtension
                                }
                            case .failure(let error):
                                print("Error fetching photo: \(error.localizedDescription)")
                            }
                        })
                    } else if utType.conforms(to: .movie) {
                        getMediaFromNSItemProvider(mediaObject.mediaItem!, typeIdentifier: mediaObject.mediaIdentifier ?? "", completion: { result in
                            switch result {
                            case .success(let url):
                                videoUrl = url
                                if let index = selectedMedia.items.firstIndex(of: mediaObject) {
                                    selectedMedia.items[index].mediaURL = url
                                    selectedMedia.items[index].mediaType = "video"
                                    selectedMedia.items[index].mediaExtension = url.pathExtension
                                }
                            case .failure(let error):
                                print("Error fetching photo: \(error.localizedDescription)")
                            }
                        })
                    }
                }
            }
        }
//        if let utType = UTType(selectedMedia.mediaIdentifier ?? "") {
//            if utType.conforms(to: .image) {
//                if let mediaData = selectedMedia.mediaData {
//                    Image(uiImage: UIImage(data: mediaData)!)
//                }
//            } else if utType.conforms(to: .movie) {
//                if let mediaURL = selectedMedia.mediaURL {
//                    VideoPlayer(player: AVPlayer(url: mediaURL))
//                }
//            } else {
                //self.getPhoto(from: itemProvider, isLivePhoto: true)
//                AsyncImage(
//                    url: selectedMedia.mediaURL,
//                    content: { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    },
//                    placeholder: {
//                        // Placeholder view or ProgressView
//                        Rectangle()
//                            .fill(Color.gray)
//                    }
//                )
//                .frame(maxHeight: .infinity)
//                .background(Color.black)
//            }
//        }
    }
}

struct ShowData: View {
    
    var data: Data
    
    @State private var videoURL: URL?
    
    var body: some View {
        Group {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.size.width, height: 250)
                    .id(data)
                    .background(Color.black)
            } else {
                if let videoURL = videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                }
            }
        }
        .onAppear {
            getURL(data: data, completionHandler: {  result in
                switch result {
                case .success(let url):
                    videoURL = url
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            })
        }
    }
    
    // MARK: - getURL
    func getURL(data: Data?, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
        let url = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString)")
        if let data = data {
            do {
                // Step 3: write to temp App file directory and return in completionHandler
                try data.write(to: url)
                completionHandler(.success(url))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    /// from: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
}

class PickedMediaItems : ObservableObject {
    @Published var items: [URL] = []
    
}

struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    
    @Binding var mediaItems: SelectedMedia
    
    var allowOneSelection = false
    
    var didFinishPicking: (_ didSelectItems: Bool) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos, .livePhotos])
        config.selectionLimit = allowOneSelection ? 1 : 0
        config.preferredAssetRepresentationMode = .current
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    
    class Coordinator: PHPickerViewControllerDelegate {
        var photoPicker: PhotoPicker
        
        init(with photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            photoPicker.didFinishPicking(!results.isEmpty)
            
            guard !results.isEmpty else {
                return
            }
            
            for result in results {
                if self.photoPicker.mediaItems.items.count>0 {
                    self.photoPicker.mediaItems.items.append(MediaObject(result))
                } else {
                    self.photoPicker.mediaItems.items = [MediaObject(result)]
                }
//                self.photoPicker.mediaItems.items.append(MediaObject(result))
//                let itemProvider = result.itemProvider
//
//                guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
//                      let utType = UTType(typeIdentifier)
//                else { continue }
//
////                if utType.conforms(to: .image) {
////                    self.getPhoto(from: itemProvider, isLivePhoto: false)
////                } else if utType.conforms(to: .movie) {
//                    self.getVideo(from: itemProvider, typeIdentifier: typeIdentifier)
////                } else {
////                    self.getPhoto(from: itemProvider, isLivePhoto: true)
////                }
            }
        }
        
        
        private func getPhoto(from itemProvider: NSItemProvider, isLivePhoto: Bool) {
            let objectType: NSItemProviderReading.Type = !isLivePhoto ? UIImage.self : PHLivePhoto.self
            
            if itemProvider.canLoadObject(ofClass: objectType) {
                itemProvider.loadObject(ofClass: objectType) { object, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    if !isLivePhoto {
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
//                                self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: image))
                            }
                        }
                    } else {
                        if let livePhoto = object as? PHLivePhoto {
                            DispatchQueue.main.async {
//                                self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: livePhoto))
                            }
                        }
                    }
                }
            }
        }
        
        
        private func getVideo(from itemProvider: NSItemProvider, typeIdentifier: String) {
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
                    
                    DispatchQueue.main.async {
//                        self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: targetURL))
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct PhotoPickerModel: Equatable {
    enum MediaType {
        case photo, video, livePhoto
    }
    
    var id: String
    var photo: UIImage?
    var url: URL?
    var livePhoto: PHLivePhoto?
    var mediaType: MediaType = .photo
    
    init(with photo: UIImage) {
        id = UUID().uuidString
        self.photo = photo
        mediaType = .photo
    }
    
    init(with videoURL: URL) {
        id = UUID().uuidString
        url = videoURL
        mediaType = .video
    }
    
    init(with livePhoto: PHLivePhoto) {
        id = UUID().uuidString
        self.livePhoto = livePhoto
        mediaType = .livePhoto
    }
    
    mutating func delete() {
        switch mediaType {
            case .photo: photo = nil
            case .livePhoto: livePhoto = nil
            case .video:
                guard let url = url else { return }
                try? FileManager.default.removeItem(at: url)
                self.url = nil
        }
    }
}

//class PickedMediaItems: ObservableObject {
//    @Published var items = [PhotoPickerModel]()
//
//    func append(item: PhotoPickerModel) {
//        items.append(item)
//    }
//
//    func deleteAll() {
//        for (index, _) in items.enumerated() {
//            items[index].delete()
//        }
//
//        items.removeAll()
//    }
//}
